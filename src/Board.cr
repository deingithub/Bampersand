require "./Config"
require "./Util"

module Board
	extend self
	def handle_reaction(client, payload)
		return unless Util.guild?(client, payload.channel_id)
		guild = Util.guild(client, payload.channel_id)
		config = Config.s(guild)
		return unless config[:f_board]
		return unless payload.emoji.name == config[:board_emoji]
		message = client.get_channel_message(
			payload.channel_id,
			payload.message_id
		)
		puts "Received Reaction #{payload.emoji} on Message #{payload.message_id}"
		return if message.reactions.as(Array(Discord::Reaction)).find do |element|
			element.emoji.name == config[:board_emoji]
		end.as(Discord::Reaction).count < config[:board_min_reacts]
		puts "oh boy"
	end
end
