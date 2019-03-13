require "../Commands"

module CommandsCore
	include Commands
	PING = ->(args : Array(String), ctx : CommandContext) {
		["Pyongyang!", "Ping!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample
	}
	HELP = ->(args : Array(String), ctx : CommandContext) {
		acc = "**B& VERSION #{Bampersand::VERSION}**\n"
		COMMANDS_AND_WHERE_TO_FIND_THEM.each do |(name, data)|
			acc += "| #{name} — #{data[:desc]}\n"
		end
		acc += "See https://15318.de/bampersand for detailed information."
		acc
	}
	CONFIG_SUBCOMMANDS = ["mirror", "board"]
	CONFIG = ->(args: Array(String), ctx: CommandContext) {
		if args.size == 0
			return <<-STR
			| config mirror <#channel | halt>
			| config board <emoji #channel min_reacts | halt>
			STR
		end
		raise "Unknown subcommand" unless CONFIG_SUBCOMMANDS.includes? args[0]
		"hulp"
	}
end
