module Util
	extend self
	def guild?(client, channel_id)
		channel = client.cache.as(Discord::Cache).resolve_channel(channel_id)
		return !channel.guild_id.nil?
	end
	def guild(client, channel_id)
		channel = client.cache.as(Discord::Cache).resolve_channel(channel_id)
		return channel.guild_id.as(Discord::Snowflake)
	end
	def channel(client, channel_id)
		begin
			channel = client.cache.as(Discord::Cache).resolve_channel(
				channel_id.delete("<#>").to_u64
			)
		rescue e
			return nil
		end
	end
	def perms?(client, user_id, guild_id, permissions)
		member = client.cache.as(Discord::Cache).resolve_member(guild_id, user_id)
		roles = member.roles.map do |element|
			client.cache.as(Discord::Cache).resolve_role(element)
		end
		roles.any? do |element|
			element.permissions.includes?(permissions) || element.permissions.includes?(Discord::Permissions::Administrator)
		end
	end
end
