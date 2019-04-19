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
    get_highest(guild_id, user_id) >= level
  end
  def get_highest(guild_id, user_id)
    return Level::Operator if user_id == Bampersand::CONFIG["admin"].to_u64
    return Level::User if guild_id.nil?
    guild_id = guild_id.not_nil!
    return Level::Owner if user_id == Bampersand::CACHE.resolve_guild(guild_id).owner_id.to_u64
    guild_perms = @@perms[guild_id]?
    if guild_perms && guild_perms[Level::Admin]?
      member = Bampersand::CACHE.resolve_member(guild_id, user_id)
      role_id = guild_perms[Level::Admin]
      return Level::Admin if member.roles.any? { |role| role.to_u64 == role_id }
    end
    if guild_perms && guild_perms[Level::Moderator]?
      member = Bampersand::CACHE.resolve_member(guild_id, user_id)
      role_id = guild_perms[Level::Moderator]
      return Level::Moderator if member.roles.any? { |role| role.to_u64 == role_id }
    end
    return Level::User
  end

  def update_perms(guild_id, level, role_id)
    @@perms[guild_id] = {} of Level => UInt64? unless @@perms[guild_id]?
    @@perms[guild_id][level] = role_id
    Bampersand::DATABASE.exec "insert into perms values (?,?,?)", guild_id.to_i64, @@perms[guild_id][Level::Admin]?.try(&.to_i64), @@perms[guild_id][Level::Moderator]?.try(&.to_i64)
  end

  macro assert_level(level)
    raise "Unauthorized. Required: {{level}}" unless Perms.check(ctx.guild_id, ctx.issuer.id.to_u64, Perms::Level::{{level}})
  end
end
