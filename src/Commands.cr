module Commands
	extend self
	alias CommandType = Proc(Array(String), CommandContext, CommandResult)
	alias CommandContext = {issuer: Discord::User}
	alias CommandResult = String
	alias CommandInfo = {fun: CommandType, desc: String}
	def contextualize(msg : Discord::Message)
		{issuer: msg.author}
	end
	def handle_message(client, cfg, msg)
		return unless msg.content.starts_with?(cfg["prefix"])
		content = msg.content.lchop(cfg["prefix"])
		arguments = content.split(" ")
		command = arguments.shift
		return unless COMMANDS_AND_WHERE_TO_FIND_THEM[command]?
		output = ""
		begin
			LOG.info "#{msg.author.username}##{msg.author.discriminator} issued #{command} #{arguments}"
			output = COMMANDS_AND_WHERE_TO_FIND_THEM[command][:fun].call(
				arguments,
				contextualize(msg)
			)
		rescue e
			output = ":x: Error executing command.\n`#{e}`"
			LOG.error e
		end
		client.create_message(msg.channel_id, output)
	end
end

require "./commands/*"

#I'm not even sorry to be honest
COMMANDS_AND_WHERE_TO_FIND_THEM = {
	"ping" => {fun: CommandsCore::PING, desc: "Hewwo n_n"},
	"help" => {fun: CommandsCore::HELP, desc: "What does this bot even do"},
	"hulp" => {fun: CommandsMemes::HULP, desc: ":eyes:"},
	"leo" => {fun: CommandsUtil::LEO, desc: "Shorten URLs using leo.immobilien"},
}
