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
		rescue e
			output = ":x: Error executing command.\n`#{e}`"
			Log.error "Failed to execute: #{e}"
		end
		client.create_message(msg.channel_id, output)
	end
end

require "./commands/*"

#I'm not even sorry to be honest
COMMANDS_AND_WHERE_TO_FIND_THEM = {
	"ping" => {fun: CommandsCore::PING, desc: "Check if the Bot's still alive"},
	"help" => {fun: CommandsCore::HELP, desc: "This command."},
	"leo" => {fun: CommandsUtil::LEO, desc: "Shorten URLs using leo.immobilien"},
	"config" => {fun: CommandsCore::CONFIG, desc: "Configure per-guild settings"},
}
