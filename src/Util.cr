module Util
  # Some utility functions
  extend self

  # Get (nilable) guild id from a channel id
  def guild(client, channel_id)
    channel = CACHE.resolve_channel(channel_id)
    channel.guild_id
  end

  # Check discord permissions by evaluating all roles the user has
  def perms?(context, permissions)
    user_id = context.issuer.id
    return true if user_id == ENV["admin"].to_u64
    return true if context.guild_id.nil?
    guild_id = context.guild_id.not_nil!
    member = CACHE.resolve_member(guild_id, user_id)
    roles = member.roles.map do |element|
      CACHE.resolve_role(element)
    end
    roles.any? do |element|
      element.permissions.includes?(permissions) ||
        element.permissions.includes?(Discord::Permissions::Administrator)
    end
  end

  macro assert_perms(context, permissions)
    unless Util.perms?({{context}}, Discord::Permissions::{{permissions}})
      raise "Insufficient permissions. Required: {{permissions}}"
    end
  end

  # Currently not needed as all guild-requiring commands are level-privileged
  def assert_guild(context)
    raise "This command can only be used in guilds" if context.message.guild_id.nil?
    context.message.guild_id.not_nil!
  end

  # Helper for the Board system, stringifies custom and unicode emoji
  def reaction_to_s(emoji)
    if emoji.id.nil?
      emoji.name
    else
      "<:#{emoji.name}:#{emoji.id}>"
    end
  end
end
