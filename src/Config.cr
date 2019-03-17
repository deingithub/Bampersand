#Configuration Store for Bampersand.
#There are two distinct config "types": Foundation and State.
#
#**Foundation** is loaded from a file on startup and includes globally used data that can't be changed during operation, i.e. auth token, prefix, client id etc.
#
#**State** is loaded from a DB on startup (TODO: Actually do that) and can be changed at runtime. Is contains guild-specific data.
module Config
	extend self

	alias Foundation = NamedTuple(client: UInt64, token: String, prefix: String)
	alias GuildState = NamedTuple(
		f_mirroring: Bool,
		out_channel: UInt64,
		in_channel: UInt64,
		f_board: Bool,
		board_emoji: String,
		board_channel: UInt64,
		board_min_reacts: UInt32
	)

	@@foundation : Foundation = load_foundation("config.ini")
	@@state : Hash(UInt64, GuildState) = {
		552249406808653836u64 => {
			f_mirroring: false,
			out_channel: 554696757175648259u64,
			in_channel: 553000426128015360u64,
			f_board: true,
			board_emoji: "⭐",
			board_channel: 554696757175648259u64,
			board_min_reacts: 1u32
		},
		472734482206687243u64 => {
			f_mirroring: true,
			out_channel: 530502868084457540u64,
			in_channel: 506598595496116244u64,
			f_board: false,
			board_emoji: "",
			board_channel: 0u64,
			board_min_reacts: 0u32
		}
	}

	#Getter for Foundation
	def f
		@@foundation
	end

	#Getter for State of a guild
	def s(guild_id)
		return default_state unless @@state[guild_id]
		@@state[guild_id]
	end

	#Is there a State for this guild available?
	def s?(guild_id)
		@@state[guild_id]?
	end

	#Modify State for a guild
	def mod_s(guild_id, update)
		@@state[guild_id] = default_state unless s?(guild_id)
		@@state[guild_id] = @@state[guild_id].merge(update)
	end

	def load_foundation(path) : Foundation
		vals = INI.parse(File.read(path))["foundation"]
		{
			client: vals["client"].to_u64,
			token: vals["token"],
			prefix: vals["prefix"]
		}
	end

	def default_state : GuildState
		{
			f_mirroring: false,
			out_channel: 0u64,
			in_channel: 0u64,
			f_board: false,
			board_emoji: "",
			board_channel: 0u64,
			board_min_reacts: 0u32
		}
	end
end
