module Mirroring
	extend self
	def handle_message(client, msg)
		guild = msg.guild_id
		return unless Config.s?(guild)
		return unless Config.s(guild)[:in_channel]? && Config.s(guild)[:out_channel]?
		return unless msg.channel_id == Config.s(guild)[:in_channel].to_u64
		begin
			client.create_message(
				Config.s(guild)[:out_channel].to_u64,
				"",
				embed: format_message(msg.author, msg.timestamp, msg.content)
			)
		rescue e
			Log.error "Failed to mirror message #{msg.id}: #{e}"
		end
	end

	def format_message(author, timestamp, content)
		Discord::Embed.new(
			title: "#{author.username}##{author.discriminator} (#{author.id})",
			description: content,
			timestamp: timestamp
		)
	end
end
