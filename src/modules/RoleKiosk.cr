module RoleKiosk
  # This module handles role kiosks, allowing users to obtain roles
  # by reacting to messages.
  extend self

  # Maps Message ID to Reaction string and associated RoleID
  @@role_kiosks : Hash(UInt64, Hash(String, UInt64)) = ->{
    kiosks = {} of UInt64 => Hash(String, UInt64)
    DATABASE.query(
      "select message_id, data from role_kiosks"
    ) do |rs|
      rs.each do
        mid = rs.read(Int64).to_u64
        data = rs.read(String)
        emojis = [] of String
        roles = [] of UInt64
        data.split(";") { |arg|
          split = arg.split("|")
          emojis << split[0]
          roles << split[1].to_u64
        }
        kiosks[mid] = Hash.zip(emojis, roles)
      end
    end
    kiosks
  }.call

  def update_kiosk(message_id, data_string)
    DATABASE.exec("insert into role_kiosks (message_id, data) values (?,?)", message_id.to_i64, data_string)
    emojis = [] of String
    roles = [] of UInt64
    data_string.split(";") { |arg|
      split = arg.split("|")
      emojis << split[0]
      roles << split[1].to_u64
    }
    @@role_kiosks[message_id] = Hash.zip(emojis, roles)
  end

  def kiosk(message_id)
    @@role_kiosks[message_id]?
  end

  def delete_kiosk(message_id)
    DATABASE.exec("delete from role_kiosks where message_id = ?", message_id.to_i64)
    @@role_kiosks.delete(message_id)
  end

  def handle_reaction_add(payload)
    return if CACHE.resolve_user(payload.user_id).bot
    lookup = @@role_kiosks[payload.message_id.to_u64]?
    return unless lookup
    target_role = lookup[Util.reaction_to_s(payload.emoji)]?
    return unless target_role
    LOG.info("Adding Role #{target_role} in #{payload.guild_id} to #{CACHE.resolve_user(payload.user_id).tag}")
    begin
      BOT.add_guild_member_role(payload.guild_id.not_nil!.to_u64, payload.user_id.to_u64, target_role)
    rescue e
      LOG.error("Error while adding role: #{e}")
    end
  end

  def handle_reaction_remove(payload)
    return if CACHE.resolve_user(payload.user_id).bot
    lookup = @@role_kiosks[payload.message_id.to_u64]?
    return unless lookup
    target_role = lookup[Util.reaction_to_s(payload.emoji)]?
    return unless target_role
    LOG.info("Removing Role #{target_role} in #{payload.guild_id} from #{CACHE.resolve_user(payload.user_id).tag}")
    begin
      BOT.remove_guild_member_role(payload.guild_id.not_nil!.to_u64, payload.user_id.to_u64, target_role)
    rescue e
      LOG.error("Error while removing role: #{e}")
    end
  end

  LOG.info("Loaded RoleKiosk Module: #{@@role_kiosks.size} active kiosks")
end
