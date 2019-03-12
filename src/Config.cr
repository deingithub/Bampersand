#Configuration Store for Bampersand.
#There are two distinct config "types": Foundation and State.
#
#**Foundation** is loaded from a file on startup and includes globally used data that can't be changed during operation, i.e. auth token, prefix, client id etc.
#
#**State** is loaded from a DB on startup (TODO: Actually do that) and can be changed at runtime. Is contains guild-specific data.
module Config
	extend self

	alias Foundation = NamedTuple(client: UInt64, token: String, prefix: String)
	alias GuildState = NamedTuple(out_channel: UInt64, in_channel: UInt64, board_active: Bool)

	@@foundation : Foundation = load_foundation("config.ini")
	@@state : Hash(UInt64, GuildState) = {
		552249406808653836u64 => {
			out_channel: 554696757175648259u64,
			in_channel: 553000426128015360u64,
			board_active: true,
		},
		472734482206687243u64 => {
			out_channel: 530502868084457540u64,
			in_channel: 506598595496116244u64,
			board_active: false,
		}
	}

	#Getter for Foundation
	def f
		@@foundation
	end

	#Getter for State of a guild
	def s(guild_id)
		@@state[guild_id]
	end

	#Is there a State for this guild available?
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
