require "../Commands"

module CommandsHulp
	include Commands
	HULP = ->(args : Array(String), ctx : CommandContext) {
		return "Ffs\nDon't do that again <@#{ctx[:issuer].id}>. Look at my flair\nI only need 0.001% of my power to wipe you out" unless ctx[:issuer].id == Bampersand::CONFIG[:admin]
		"`\#TODO`"
	}
end
