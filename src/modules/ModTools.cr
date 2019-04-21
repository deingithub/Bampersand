module ModTools
  # This module handles setting up/fetching mute roles and enforcing slowmode
  # for users with manage_messages permissions.
  extend self

  # Tries to get the mute role for a guild
  def mute_role?(guild_id)
    mute_role_id = cache!.guild_roles[guild_id].find do |role_id|
      cache!.resolve_role(role_id).name == "B& Muted"
    end
    return cache!.resolve_role(mute_role_id) unless mute_role_id.nil?
    nil
  end

  # Creates a new role, override-denies write permissions for all channels B&
  # can see, and raises as far to the top as possible.
  def create_mute_role(guild_id)
    mute_role = bot!.create_guild_role(guild_id, "B& Muted")
    cache!.guild_channels(guild_id).each do |channel_id|
      bot!.edit_channel_permissions(channel_id, mute_role.id, "role", Discord::Permissions::None, Discord::Permissions::SendMessages)
    end
    current_user = cache!.resolve_current_user
    member = cache!.resolve_member(guild_id, current_user.id)
    position = member.roles.map do |role_id|
      cache!.resolve_role(role_id).position
    end.max
    bot!.modify_guild_role_positions(guild_id, [Discord::REST::ModifyRolePositionPayload.new(mute_role.id, position)])
    cache!.cache(mute_role)
    cache!.add_guild_role(guild_id, mute_role.id)
    mute_role
  end

  # Maps Channel-ID => Cooldown in sec
  @@slowmodes : Hash(UInt64, UInt32) = load_slowmodes

  def load_slowmodes
    slowmodes = {} of UInt64 => UInt32
    Bampersand::DATABASE.query "select * from slowmodes" do |rs|
      raise "Invalid column count #{rs.column_count}" unless rs.column_count == 2
      rs.each do
        slowmodes[rs.read(Int64).to_u64] = rs.read(Int64).to_u32
      end
    end
    slowmodes
  end

  # Maps Channel-ID => (User-Id => Timestamp)
  @@last_msgs = {} of UInt64 => Hash(UInt64, Time)

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

  # Deletes messages whose authors have already written before the cooldown
  # elapsed and DMs them the deleted content.
  def enforce_slowmode(msg)
    cooldown = @@slowmodes[msg.channel_id]?
    return if cooldown.nil?
    if @@last_msgs[msg.channel_id.to_u64]?.nil?
      @@last_msgs[msg.channel_id.to_u64] = {} of UInt64 => Time
    end
    channel_data = @@last_msgs[msg.channel_id]
    last_timestamp = channel_data[msg.author.id]?
    last_timestamp = Time.unix(0) if last_timestamp.nil?
    if Time.utc_now - last_timestamp > Time::Span.new(0, 0, cooldown)
      @@last_msgs[msg.channel_id][msg.author.id.to_u64] = msg.timestamp
    else
      Log.debug("Enforcing slowmode on message #{msg.id} by #{msg.author.username}##{msg.author.discriminator} in #{msg.channel_id}. RIP.")
      begin
        bot!.delete_message(msg.channel_id, msg.id)
        dm = bot!.create_dm(msg.author.id).id
        bot!.create_message(
          dm,
          "Your message in <##{msg.channel_id}> has been removed due to slowmode enforcement. Here's the text in case you want to post it later:",
          # Posting it as embed circumvents the 2000 char limit.
          Discord::Embed.new(description: msg.content)
        )
      rescue e
        Log.warn("Failed to enforce slowmode: #{e}")
      end
    end
  end

  Log.info("Loaded ModTools Module: #{@@slowmodes.size} channels with slowmode")
end
