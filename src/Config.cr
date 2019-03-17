#Configuration Store for Bampersand.
#There are two distinct config "types": Foundation and State.
#
#**Foundation** is loaded from a file on startup and includes globally used data that can't be changed during operation, i.e. auth token, prefix, client id etc.
#
#**State** is loaded from a DB on startup (TODO: Actually do that) and can be changed at runtime. Is contains guild-specific data.
module Config
	extend self
	STATE_FILE = "state.ini"

	alias Foundation = NamedTuple(client: UInt64, token: String, prefix: String, admin: UInt64)
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
	@@state : Hash(UInt64, GuildState) = load_state(STATE_FILE)

	#Getter for Foundation
	def f
		@@foundation
	end

	#Getter for State of a guild
	def s(guild_id)
		return default_state unless @@state.has_key? guild_id
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
		output = INI.build(@@state, true)
		File.write(STATE_FILE, output)
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

	def load_state(path) : Hash(UInt64, GuildState)
		INI.parse(File.read(path))
			.transform_keys { |key| key.to_u64 }
			.transform_values do |value|
				{
					f_mirroring: value["f_mirroring"] == "true" ? true : false,
					out_channel: value["out_channel"].to_u64,
					in_channel: value["in_channel"].to_u64,
					f_board: value["f_board"] == "true" ? true : false,
					board_emoji: value["board_emoji"],
					board_channel: value["board_channel"].to_u64,
					board_min_reacts: value["board_min_reacts"].to_u32
				}
			end
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
