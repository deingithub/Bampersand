require "./Bampersand"

module ModTools
  extend self
  @@slowmodes : Hash(UInt64, UInt32) = load_slowmodes
  @@last_msgs = {} of UInt64 => Hash(UInt64, Time)

  def mute_role?(guild_id)
    mute_role_id = Bampersand::CACHE.guild_roles[guild_id].find do |role_id|
      Bampersand::CACHE.resolve_role(role_id).name == "B& Muted"
    end
    return Bampersand::CACHE.resolve_role(mute_role_id) unless mute_role_id.nil?
    nil
  end
  def create_mute_role(guild_id)
    mute_role = Bampersand::CLIENT.create_guild_role(guild_id, "B& Muted")
    Bampersand::CACHE.guild_channels(guild_id).each do |channel_id|
      Bampersand::CLIENT.edit_channel_permissions(channel_id, mute_role.id, "role", Discord::Permissions::None, Discord::Permissions::SendMessages)
    end
    Bampersand::CACHE.cache(mute_role)
    Bampersand::CACHE.add_guild_role(guild_id, mute_role.id)
    mute_role
  end

  def load_slowmodes
    slowmodes = {} of UInt64 => UInt32
    Bampersand::DATABASE.query "select * from slowmodes" do |rs|
      raise "Invalid column count #{rs.column_count}" unless rs.column_count == 2
      rs.each do
        slowmodes[rs.read(Int64).to_u64] = rs.read(Int64).to_u32
      end
    end
    puts slowmodes
    slowmodes
  end

  def set_channel_slowmode(channel_id, secs)
    @@slowmodes[channel_id] = secs
    @@last_msgs[channel_id] = {} of UInt64 => Time
    Bampersand::DATABASE.exec "insert into slowmodes values (?, ?)", channel_id.to_i64, secs.to_i64
  end

  def remove_channel_slowmode(channel_id)
    @@slowmodes.delete(channel_id)
    @@last_msgs.delete(channel_id)
    Bampersand::DATABASE.exec "delete from slowmodes where channel_id == ?", channel_id.to_i64
  end

  def get_channel_slowmode(channel_id)
    @@slowmodes[channel_id]?
  end

  def enforce_slowmode(msg)
    cooldown = @@slowmodes[msg.channel_id]?
    return if cooldown.nil?
    if @@last_msgs[msg.channel_id.to_u64]?.nil?
      @@last_msgs[msg.channel_id.to_u64] = {} of UInt64 => Time
    end
    channel_data = @@last_msgs[msg.channel_id]
    last_timestamp = channel_data[msg.author.id]?
    last_timestamp = Time.unix(0) if last_timestamp.nil?
    if Time.now - last_timestamp > Time::Span.new(0, 0, cooldown)
      @@last_msgs[msg.channel_id][msg.author.id.to_u64] = msg.timestamp
    else
      Log.debug("Enforcing slowmode on message #{msg.id} by #{msg.author.username}##{msg.author.discriminator} in #{msg.channel_id}. RIP.")
      begin
        Bampersand::CLIENT.delete_message(msg.channel_id, msg.id)
        dm = Bampersand::CLIENT.create_dm(msg.author.id).id
        Bampersand::CLIENT.create_message(
          dm,
          "Your message in <##{msg.channel_id}> has been removed due to slowmode enforcement. Here's the text in case you want to post it later:",
          Discord::Embed.new(description: msg.content)
        )
      rescue e
        Log.warn("Failed to enforce slowmode: #{e}")
      end
    end
  end
end
