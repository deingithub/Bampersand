module Config
	extend self

	alias Foundation = NamedTuple(client: UInt64, token: String, prefix: String)

	@@foundation : Foundation = load_foundation("config.ini")
	@@state = {
		552249406808653836u64 => {
			:out_channel => 554696757175648259u64,
			:in_channel => 553000426128015360u64
		}
	}

	def f
		@@foundation
	end
	def s(guild_id)
		@@state[guild_id]
	end
	def s?(guild_id)
		@@state[guild_id]?
	end

	def load_foundation(path) : Foundation
		vals = INI.parse(File.read(path))["foundation"]
		{
			client: vals["client"].to_u64,
			token: vals["token"],
			prefix: vals["prefix"]
		}
	end
end
