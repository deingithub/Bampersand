module Util
  extend self

  def guild(client, channel_id)
    channel = client.cache.as(Discord::Cache).resolve_channel(channel_id)
    return channel.guild_id
  end

  def perms?(context, permissions)
    user_id = context[:issuer].id
    return true if user_id == Bampersand::CONFIG["admin"]
    return true if context[:guild_id].nil?
    guild_id = context[:guild_id].not_nil!
    client = Bampersand::CLIENT
    member = client.cache.as(Discord::Cache).resolve_member(guild_id, user_id)
    roles = member.roles.map do |element|
      client.cache.as(Discord::Cache).resolve_role(element)
    end
    roles.any? do |element|
      element.permissions.includes?(permissions) || element.permissions.includes?(Discord::Permissions::Administrator)
    end
  end

  macro assert_perms(context, permissions)
    raise "Insufficient permissions" unless Util.perms?({{context}}, Discord::Permissions::{{permissions}})
  end
  def assert_guild(context)
    raise "This command can only be used in guilds" if context[:guild_id].nil?
  end

  def reaction_to_s(emoji)
    if emoji.id.nil?
      emoji.name
    else
      "<:#{emoji.name}:#{emoji.id}>"
    end
  end
end
