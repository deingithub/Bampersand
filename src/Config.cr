#Foundation Config Store for Bampersand.
#There are two distinct config "types": Foundation and State.
#
#**Foundation** is loaded from a file on startup and includes globally used data that can't be changed during operation, i.e. auth token, prefix, client id etc.
#
#**State** is loaded from a DB on startup and can be changed at runtime. Is contains guild-specific data.
module Config
	extend self
	alias Foundation = NamedTuple(client: UInt64, token: String, prefix: String, admin: UInt64)
	@@foundation : Foundation = load_foundation("config.ini")

	#Getter for Foundation
	def f
		@@foundation
	end
	def load_foundation(path) : Foundation
		vals = INI.parse(File.read(path))["foundation"]
		{
			client: vals["client"].to_u64,
			token: vals["token"],
			prefix: vals["prefix"],
			admin: vals["admin"].to_u64
		}
	end
end
