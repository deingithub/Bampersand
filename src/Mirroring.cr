module Mirroring
	extend self
	def handle_message(client, msg)
		guild = msg.guild_id
		return unless State.feature? guild, State::Features::Mirror
		return unless msg.channel_id == State.get(guild)[:mirror_in]
		begin
			client.create_message(
				State.get(guild)[:mirror_out],
				"",
				embed: format_message(msg)
			)
		rescue e
			Log.error "Failed to mirror message #{msg.id}: #{e}"
		end
	end

	def format_message(msg)
		content = if msg.content.size == 0
			"`[empty message]`"
		else
			msg.content
		end
		Discord::Embed.new(
			title: "#{msg.author.username}##{msg.author.discriminator} (#{msg.author.id})",
			description: content,
			timestamp: msg.timestamp
		)
	end
end
