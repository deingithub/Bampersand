require "./Config"
require "./Util"

module Board
	@@board_messages = {} of UInt64 => UInt64
	extend self
	def handle_reaction(client, payload)
		# Abort if not in a guild
		return unless Util.guild?(client, payload.channel_id)
		guild = Util.guild(client, payload.channel_id)
		config = Config.s(guild)
		# Abort if a) board is disabled,
		# b) Message is from the board channel
		# c) The reaction isn't the correct emoji
		return unless config[:f_board]
		return if payload.channel_id.to_u64 == config[:board_channel]
		return unless Util.reaction_to_s(payload.emoji) == config[:board_emoji]
		message = client.get_channel_message(
			payload.channel_id,
			payload.message_id
		)
		# Abort if the amount of board-triggering reactions is below threshold
		count = message.reactions.as(Array(Discord::Reaction)).find{ |element|
			Util.reaction_to_s(element.emoji) == config[:board_emoji]
		}.as(Discord::Reaction).count
		return if count < config[:board_min_reacts]

		unless @@board_messages.has_key? payload.message_id
			begin
			posted_message = client.create_message(
				config[:board_channel],
				"",
				build_embed(
					guild,
					message,
					count,
					config[:board_emoji]
				)
			)
			@@board_messages[payload.message_id.to_u64] = posted_message.id.to_u64
			rescue e
				Log.error("Failed to post board message: #{e}")
			end
		else
			begin
			client.edit_message(
				config[:board_channel],
				@@board_messages[payload.message_id.to_u64],
				"",
				build_embed(
					guild,
					message,
					count,
					config[:board_emoji]
				)
			)
			rescue e
				Log.error("Failed to edit board message: #{e}")
			end
		end
	end
	def build_embed(guild_id, message, count, emoji)
		embed = Discord::Embed.new(
			timestamp: message.timestamp,
			author: Discord::EmbedAuthor.new(
				"#{message.author.username}##{message.author.discriminator}",
				nil,
				"https://cdn.discordapp.com/avatars/#{message.author.id}/#{message.author.avatar}"
			),
			fields: [
				Discord::EmbedField.new(
					"Message",
					"#{count}x #{emoji} — Posted to <##{message.channel_id}> — [Jump](https://discordapp.com/channels/#{guild_id}/#{message.channel_id}/#{message.id})"
				)
			],
			colour: 0x16161d_u32
		)
		if message.content.size > 0
			embed.description = message.content
		else
			embed.description = "`[Attachment]`"
		end
		embed
	end
end
