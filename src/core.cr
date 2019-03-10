require "./Commands"

module BampersandCommandsCore
	extend self
	PING = ->(args : Array(String), ctx : BampersandCommands::CommandContext) {
		"Pyongyang!"
	}
end
