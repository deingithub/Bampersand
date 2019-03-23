require "../Commands"

module CommandsCore
	include Commands
	PING = ->(args : Array(String), ctx : CommandContext) {
		#NOTE change this if VA secedes again
		rva = Time.now Time::Location.load("America/New_York")
		return ":ping_pong: It's Kat Appreciation Day, My Frens" if rva.month == 3 && rva.day == 24

		":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample
	}
	HELP = ->(args : Array(String), ctx : CommandContext) {
		acc = "**BAMPERSAND COMMANDS**\n"
		COMMANDS_AND_WHERE_TO_FIND_THEM.each do |(name, data)|
			acc += "| #{name} — #{data[:desc]}\n"
		end
		acc += "See `about` for more information."
		acc
	}
	ABOUT  = ->(args : Array(String), ctx : CommandContext) {
		uptime = Time.monotonic - Bampersand::STARTUP
		<<-STR
		**BAMPERSAND VERSION #{Bampersand::VERSION}**
		This is a simple utility bot for Discord powered by [Crystal](https://crystal-lang.org). Visit the documentation at https://15318.de/bampersand.
		Currently running on #{ctx[:client].cache.as(Discord::Cache).guilds.size} guilds, serving #{ctx[:client].cache.as(Discord::Cache).users.size} users.
		Uptime is #{uptime.days}d #{uptime.hours}h #{uptime.minutes}m #{uptime.seconds}s. Bot operator is <@#{Config.f["admin"]}>.
		STR
	}
end
