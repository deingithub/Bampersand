module Config
  # This module stores and manages guild-specific configuration.
  extend self

  alias GuildConfig = NamedTuple(
    features: Features,
    mirror_in: UInt64,
    mirror_out: UInt64,
    board_emoji: String,
    board_channel: UInt64,
    board_min_reacts: UInt32,
    join_channel: UInt64,
    join_text: String,
    leave_channel: UInt64,
    leave_text: String)

  @[Flags]
  enum Features
    Mirror
    Board
    JoinLog
    LeaveLog
  end

  # All features are disabled and values set to null-like values (not nil!)
  def default_state : GuildConfig
    {
      features:         Features::None,
      mirror_in:        0u64,
      mirror_out:       0u64,
      board_emoji:      "",
      board_channel:    0u64,
      board_min_reacts: 0u32,
      join_channel:     0u64,
      join_text:        "",
      leave_channel:    0u64,
      leave_text:       "",
    }
  end

  # Maps Guild ID => Config NT
  @@state : Hash(UInt64, GuildConfig) = ->{
    state = {} of UInt64 => GuildConfig
    DATABASE.query "select * from state" do |rs|
      rs.each do
        state[rs.read(Int64).to_u64] = {
          features:         Features.new(rs.read(Int32)),
          mirror_in:        rs.read(Int64).to_u64,
          mirror_out:       rs.read(Int64).to_u64,
          board_emoji:      rs.read(String),
          board_channel:    rs.read(Int64).to_u64,
          board_min_reacts: rs.read(Int32).to_u32,
          join_channel:     rs.read(Int64).to_u64,
          join_text:        rs.read(String),
          leave_channel:    rs.read(Int64).to_u64,
          leave_text:       rs.read(String),
        }
      end
    end
    LOG.info("Loaded Config Module: #{state.keys.size} stored states")
    state
  }.call

  # Getter defaulting to the default state
  def get(guild_id)
    return default_state unless @@state.has_key? guild_id
    @@state[guild_id]
  end

  # Don't manipulate the features enum with this, use Config#feature instead.
  def set(guild_id, update)
    new_state = get(guild_id).merge(update)
    @@state[guild_id.to_u64] = new_state
    DATABASE.exec(
      "insert into state (guild_id, features, mirror_in, mirror_out, board_emoji, board_channel, board_min_reacts, join_channel, join_text, leave_channel, leave_text) values (?,?,?,?,?,?,?,?,?,?,?)",
      guild_id.to_i64,
      new_state[:features].to_i64,
      new_state[:mirror_in].to_i64,
      new_state[:mirror_out].to_i64,
      new_state[:board_emoji],
      new_state[:board_channel].to_i64,
      new_state[:board_min_reacts].to_i32,
      new_state[:join_channel].to_i64,
      new_state[:join_text],
      new_state[:leave_channel].to_i64,
      new_state[:leave_text],
    )
  end

  # Setter for features
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

  # Getter for features
  def feature?(guild_id, feature)
    get(guild_id)[:features].includes? feature
  end
end
