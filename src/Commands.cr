module Commands
	extend self
	alias CommandType = Proc(Array(String), CommandContext, CommandResult)
	alias CommandContext = {issuer: Discord::User}
	alias CommandResult = String
	alias CommandInfo = {fun: CommandType, desc: String}
	def contextualize(msg : Discord::Message)
		{issuer: msg.author}
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
