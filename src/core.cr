require "./Commands"

module BundesministcrCommandsCore
	extend self
	PING = ->(args : Array(String), ctx : BundesministcrCommands::CommandContext) {
		"Pyongyang!"
	}
end
