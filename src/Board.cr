require "./Config"
require "./Util"

module Board
	extend self
	def handle_reaction(client, payload)
		return unless Util.guild?(client, payload.channel_id)
		guild = Util.guild(client, payload.channel_id)
		return unless Config.s?(guild)
		return unless Config.s(guild)[:f_board]
		message = client.get_channel_message(
			payload.channel_id,
			payload.message_id
		)
		puts "Received Reaction #{payload.emoji} on Message #{payload.message_id}"
	end
end
