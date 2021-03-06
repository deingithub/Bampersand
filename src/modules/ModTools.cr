module ModTools
  # This module handles setting up/fetching mute roles and enforcing slowmode
  # for users with manage_messages permissions.
  extend self

  # Tries to get the mute role for a guild
  def mute_role?(guild_id)
    mute_role_id = CACHE.guild_roles[guild_id].find do |role_id|
      CACHE.resolve_role(role_id).name == "B& Muted"
    end
    return CACHE.resolve_role(mute_role_id) unless mute_role_id.nil?
    nil
  end

  # Creates a new role, override-denies write permissions for all channels B&
  # can see, and raises as far to the top as possible.
  def create_mute_role(guild_id)
    mute_role = BOT.create_guild_role(guild_id, "B& Muted")
    CACHE.guild_channels(guild_id).each do |channel_id|
      BOT.edit_channel_permissions(
        channel_id, mute_role.id, "role",
        Discord::Permissions::None, Discord::Permissions::SendMessages
      )
    end
    current_user = CACHE.resolve_current_user
    member = CACHE.resolve_member(guild_id, current_user.id)
    position = member.roles.map do |role_id|
      CACHE.resolve_role(role_id).position
    end.max
    BOT.modify_guild_role_positions(
      guild_id,
      [Discord::REST::ModifyRolePositionPayload.new(mute_role.id, position)]
    )
    CACHE.cache(mute_role)
    CACHE.add_guild_role(guild_id, mute_role.id)
    mute_role
  end

  # Maps Channel-ID => Cooldown in sec
  @@slowmodes : Hash(UInt64, UInt32) = ->{
    slowmodes = {} of UInt64 => UInt32
    DATABASE.query "select * from slowmodes" do |rs|
      rs.each do
        slowmodes[rs.read(Int64).to_u64] = rs.read(Int64).to_u32
      end
    end
    slowmodes
  }.call

  # Maps Channel-ID => (User-Id => Timestamp)
  @@last_msgs = {} of UInt64 => Hash(UInt64, Time)

  def set_channel_slowmode(channel_id, secs)
    @@slowmodes[channel_id.to_u64] = secs
    @@last_msgs[channel_id.to_u64] = {} of UInt64 => Time
    DATABASE.exec(
      "insert into slowmodes values (?, ?)", channel_id.to_i64, secs.to_i64
    )
  end

  def remove_channel_slowmode(channel_id)
    @@slowmodes.delete(channel_id)
    @@last_msgs.delete(channel_id)
    DATABASE.exec(
      "delete from slowmodes where channel_id == ?", channel_id.to_i64
    )
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
    if msg.timestamp - last_timestamp > Time::Span.new(0, 0, cooldown)
      @@last_msgs[msg.channel_id][msg.author.id.to_u64] = msg.timestamp
    else
      LOG.debug("Enforcing slowmode on message #{msg.id} by #{msg.author.tag} in #{msg.channel_id}. RIP.")
      timeout = (msg.timestamp - last_timestamp - Time::Span.new(0, 0, cooldown)).abs
      begin
        BOT.delete_message(msg.channel_id, msg.id)
        dm = BOT.create_dm(msg.author.id).id
        BOT.create_message(
          dm,
          "Your message in <##{msg.channel_id}> has been removed due to slowmode enforcement. Here's the text in case you want to post in at least #{timeout.total_milliseconds/1000} seconds:",
          # Posting it as embed circumvents the 2000 char limit.
          Discord::Embed.new(description: msg.content)
        )
      rescue e
        LOG.warn("Failed to enforce slowmode: #{e}")
      end
    end
  end

  LOG.info("Loaded ModTools Module: #{@@slowmodes.size} channels with slowmode")
end
