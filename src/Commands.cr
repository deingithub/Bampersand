require "./core"

module BampersandCommands
	extend self
	include BampersandCommandsCore
	alias CommandType = Proc(Array(String), CommandContext, CommandResult)
	alias CommandContext = {issuer: Discord::User}
	alias CommandResult = String
	alias CommandInfo = {fun: CommandType, desc: String}
	def contextualize(msg : Discord::Message)
		{issuer: msg.author}
	end

	COMMANDS_AND_WHERE_TO_FIND_THEM = {
		"ping" => {fun: PING, desc: "Hewwo n_n"}
	}
end
