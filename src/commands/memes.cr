require "../Commands"

module CommandsMemes
	include Commands
	HULP = ->(args : Array(String), ctx : CommandContext) {
		<<-STR
		don't do that again <@#{ctx[:issuer].id}>, look at my flair.
		i only need 0.001% of my power to wipe you out
		STR
	}
end
