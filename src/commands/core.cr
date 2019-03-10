require "../Commands"

module CommandsCore
	include Commands
	PING = ->(args : Array(String), ctx : CommandContext) {
		["Pyongyang!", "Ping!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample
	}
	HELP = ->(args : Array(String), ctx : CommandContext) {
		acc = "**b& commands**\n"
		COMMANDS_AND_WHERE_TO_FIND_THEM.each do |(name, data)|
			acc += "#{name} — #{data[:desc]}\n"
		end
		acc += "See https://15318.de/bampersand for detailed information."
		acc
	}
end
