require "./Config"

module Commands
	extend self
	alias CommandType = Proc(Array(String), CommandContext, CommandResult)
	alias CommandContext = {issuer: Discord::User}
	alias CommandResult = String
	alias CommandInfo = {fun: CommandType, desc: String}
	def contextualize(msg : Discord::Message)
		{issuer: msg.author}
	end

	def handle_message(client, msg)
		return unless msg.content.starts_with?(Config.f["prefix"])
		content = msg.content.lchop(Config.f["prefix"])
		arguments = content.split(" ")
		command = arguments.shift
		return unless COMMANDS_AND_WHERE_TO_FIND_THEM[command]?
		output = ""
		begin
			Log.info "#{msg.author.username}##{msg.author.discriminator} issued #{command} #{arguments}"
			output = COMMANDS_AND_WHERE_TO_FIND_THEM[command][:fun].call(
				arguments,
				contextualize(msg)
			)
			send_result(client, msg.channel_id, command, :success, output)
		rescue e
			send_result(client, msg.channel_id, command, :error, e)
			Log.error "Failed to execute: #{e}"
		end

	end
	def send_result(client, channel_id, command, result, output)
		begin
			if result == :success
				client.create_message(channel_id, "", embed: Discord::Embed.new(
					title: "**#{command.upcase}**",
					colour: 0x16161d,
					description: output.to_s
				))
			elsif result == :error
				client.create_message(channel_id, "", embed: Discord::Embed.new(
					title: "**failed to execute: #{command}**".upcase,
					colour: 0xdd2e44,
					description: "`#{output.to_s}`"
				))
			end
		rescue e
			Log.error "Failed to deliver #{result} message to #{channel_id}: #{e}"
		end
	end
end

require "./commands/*"

#I'm not even sorry to be honest
COMMANDS_AND_WHERE_TO_FIND_THEM = {
	"ping" => {fun: CommandsCore::PING, desc: "Check if the Bot's still alive"},
	"help" => {fun: CommandsCore::HELP, desc: "This command."},
	"leo" => {fun: CommandsUtil::LEO, desc: "Shorten URLs using leo.immobilien"},
	"config" => {fun: CommandsCore::CONFIG, desc: "Configure per-guild settings"},
	"hulp" => {fun: CommandsHulp::HULP, desc: "pluh |"},
}
