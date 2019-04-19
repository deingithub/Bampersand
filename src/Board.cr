require "./Util"
require "./L10N"

module Board
  @@board_messages : Hash(UInt64, UInt64) = load_board
  extend self

  def load_board
    board_data = {} of UInt64 => UInt64
    Bampersand::DATABASE.query "select source_message, board_message from board" do |rs|
      raise "Invalid column count" unless rs.column_count == 2
      rs.each do
        board_data[rs.read(Int64).to_u64] = rs.read(Int64).to_u64
      end
    end
    Log.info("Loaded Board Module: #{board_data.size} stored board messages")
    board_data
  end

  def handle_reaction(payload)
    client = Bampersand::CLIENT
    guild = Util.guild(client, payload.channel_id)
    return unless guild
    # Abort if a) board is disabled
    return unless State.feature? guild, State::Features::Board
    # b) Message is from the board channel
    # c) The reaction isn't the correct emoji
    config = State.get(guild)
    return if payload.channel_id.to_u64 == config[:board_channel]
    return unless Util.reaction_to_s(payload.emoji) == config[:board_emoji]
    message = client.get_channel_message(payload.channel_id, payload.message_id)
    # Abort if the amount of board-triggering reactions is below threshold
    count = message.reactions.not_nil!.find { |element|
      Util.reaction_to_s(element.emoji) == config[:board_emoji]
    }.not_nil!.count
    return if count < config[:board_min_reacts]

    unless @@board_messages.has_key? payload.message_id
      begin
        posted_message = client.create_message(
          config[:board_channel],
          "",
          build_embed(guild, message, count, config[:board_emoji])
        )
        @@board_messages[payload.message_id.to_u64] = posted_message.id.to_u64
        Bampersand::DATABASE.exec(
          "insert into board (source_message, board_message) values (?,?)",
          payload.message_id.to_u64.to_i64,
          posted_message.id.to_u64.to_i64
        )
      rescue e
        Log.error("Failed to post board message: #{e}")
      end
    else
      begin
        client.edit_message(
          config[:board_channel],
          @@board_messages[payload.message_id.to_u64],
          "",
          build_embed(guild, message, count, config[:board_emoji])
        )
      rescue e
        Log.error("Failed to edit board message: #{e}")
      end
    end
  end

  def build_embed(guild_id, message, count, emoji)
    # Yes, this is very ugly.
    ctx = {guild_id: guild_id}
    jump_string = L10N.do("board_jump_string", count, emoji, message.channel_id, guild_id, message.channel_id, message.id)
    embed = Discord::Embed.new(
      timestamp: message.timestamp,
      author: Discord::EmbedAuthor.new(
        "#{message.author.username}##{message.author.discriminator}",
        nil,
        "https://cdn.discordapp.com/avatars/#{message.author.id}/#{message.author.avatar}"
      ),
      fields: [
        Discord::EmbedField.new(
          L10N.do("message"),
          jump_string
        ),
      ],
      colour: 0x16161d
    )
    embed.description = message.content
    if message.attachments.size > 0
      embed.image = Discord::EmbedImage.new(message.attachments[0].url)
    end
    embed
  end
end
