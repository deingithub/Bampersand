module Perms
  extend self

  @@perms : Hash(UInt64, Hash(Level, UInt64?)) = load_perms()

  def load_perms
    perms = {} of UInt64 => Hash(Level, UInt64?)
    Bampersand::DATABASE.query "select * from perms" do |rs|
      rs.each do
        perms[rs.read(Int64).to_u64] = {
          Level::Admin     => rs.read(Int64?).try(&.to_u64),
          Level::Moderator => rs.read(Int64?).try(&.to_u64),
        }
      end
    end
    perms
  end

  enum Level
    User; Moderator; Admin; Owner; Operator
  end

  def check(guild_id, user_id, level)
    return true if user_id == Bampersand::CONFIG["admin"].to_u64
    return true if level == Level::User
    return false if guild_id.nil?
    guild_id = guild_id.not_nil!
    guild_perms = @@perms[guild_id]?
    owner_id = Bampersand::CACHE.resolve_guild(guild_id).owner_id.to_u64
    return true if user_id == owner_id && level != Level::Operator
    raise "No permission roles configured" if guild_perms.nil?
    if level == Level::Admin
      role_id = guild_perms.not_nil![Level::Admin]?
      raise "Admin role not set" if role_id.nil?
      member = Bampersand::CACHE.resolve_member(guild_id, user_id)
      return member.roles.any? { |role| role.to_u64 == role_id }
    end
    if level == Level::Moderator
      admin_role_id = guild_perms.not_nil![Level::Admin]?
      role_id = guild_perms.not_nil![Level::Moderator]?
      raise "Moderator role not set" if role_id.nil? && admin_role_id.nil?
      member = Bampersand::CACHE.resolve_member(guild_id, user_id)
      return member.roles.any? { |role| role.to_u64 == role_id || role.to_u64 == admin_role_id }
    end
    return false
  end

  def update_perms(guild_id, level, role_id)
    @@perms[guild_id] = {} of Level => UInt64? unless @@perms[guild_id]?
    @@perms[guild_id][level] = role_id
    Bampersand::DATABASE.exec "insert into perms values (?,?,?)", guild_id.to_i64, @@perms[guild_id][Level::Admin]?.try(&.to_i64), @@perms[guild_id][Level::Moderator]?.try(&.to_i64)
  end

  macro assert_perms(context, permissions)
    raise "Unauthorized. Required: {{permissions}}" unless Perms.check({{context}}.guild_id, {{context}}.issuer.id.to_u64, Perms::Level::{{permissions}})
  end
end
