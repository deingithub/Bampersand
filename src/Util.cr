module Util
	extend self
	def guild?(client, channel_id)
		channel = client.cache.as(Discord::Cache).resolve_channel(channel_id)
		return channel.guild_id.nil?
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
end
