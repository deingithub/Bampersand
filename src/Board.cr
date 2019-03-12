require "./Config"

module Board
	extend self
	def handle_reaction(client, payload)
		channel = client.cache.as(Discord::Cache).resolve_channel(payload.channel_id)
		guild = if channel.guild_id.nil?
				return
			else
				channel.guild_id
			end
		return unless Config.s?(guild)
		return unless Config.s(guild)[:board_active]
		message = client.get_channel_message(
			payload.channel_id,
			payload.message_id
		)
		puts "Received Reaction #{payload.emoji} on Message #{payload.message_id}"
	end
end
