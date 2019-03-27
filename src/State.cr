require "db"

module State
	extend self

	alias GuildState = NamedTuple(
	features: Features,
	mirror_in: UInt64,
	mirror_out: UInt64,
	board_emoji: String,
	board_channel: UInt64,
	board_min_reacts: UInt32
	)
	def default_state : GuildState
		{
			features: Features::None,
			mirror_in: 0u64,
			mirror_out: 0u64,
			board_emoji: "",
			board_channel: 0u64,
			board_min_reacts: 0u32
		}
	end

	@@state : Hash(UInt64, GuildState) = load_state()
	def load_state()
		state = {} of UInt64 => GuildState
		Bampersand::DATABASE.query "select guild_id, features, mirror_in, mirror_out, board_emoji, board_channel, board_min_reacts from state" do |rs|
			# Adjust expected column count when the data schema is changed
			raise "Invalid column count" unless rs.column_count == 1 + 6
			rs.each do
				state[rs.read(Int64).to_u64] = {
					features: Features.new(rs.read(Int32)),
					mirror_in: rs.read(Int64).to_u64,
					mirror_out: rs.read(Int64).to_u64,
					board_emoji: rs.read(String),
					board_channel: rs.read(Int64).to_u64,
					board_min_reacts: rs.read(Int32).to_u32
				}
			end
		end
		state
	end

	def get(guild_id)
		return default_state unless @@state.has_key? guild_id
		@@state[guild_id]
	end
	def set(guild_id, update)
		new_state = @@state[guild_id].merge(update)
		@@state[guild_id] = new_state
		Bampersand::DATABASE.exec "insert into state (guild_id, features, mirror_in, mirror_out, board_emoji, board_channel, board_min_reacts) values (?,?,?,?,?,?,?)", guild_id.to_i64, new_state[:features].to_i64, new_state[:mirror_in].to_i64, new_state[:mirror_out].to_i64, new_state[:board_emoji], new_state[:board_channel].to_i64, new_state[:board_min_reacts].to_i32
	end
	def feature(guild_id, feature, state)
		current_set = get(guild_id)[:features]
		new_set = if state
				current_set | feature
			elsif current_set.includes? feature
				current_set - feature.value
			else
				current_set
			end
		set(guild_id, {features: new_set})
	end
	def feature?(guild_id, feature)
		get(guild_id)[:features].includes? feature
	end

	@[Flags]
	enum Features
		Mirror
		Board
	end
end
