module Board
  # This module handles the reaction based best-of tracker.
  extend self

  # Maps Message-ID => Message-ID
  @@board_messages : Hash(UInt64, UInt64) = load_board

  def load_board
    board_data = {} of UInt64 => UInt64
    Bampersand::DATABASE.query(
      "select source_message, board_message from board"
    ) do |rs|
      raise "Invalid column count" unless rs.column_count == 2
      rs.each do
        board_data[rs.read(Int64).to_u64] = rs.read(Int64).to_u64
      end
    end
    Log.info("Loaded Board Module: #{board_data.size} stored board messages")
    board_data
  end

  # The event handler calls this.
  def handle_reaction(payload)
    guild = Util.guild(bot!, payload.channel_id)
    return unless guild
    # Abort if a) board is disabled
    return unless State.feature? guild, State::Features::Board
    # b) Message is from the board channel
    # c) The reaction isn't the correct emoji
    config = State.get(guild)
    return if payload.channel_id.to_u64 == config[:board_channel]
    return unless Util.reaction_to_s(payload.emoji) == config[:board_emoji] || config[:board_emoji] == "*"
    message = bot!.get_channel_message(payload.channel_id, payload.message_id)
    # Get the "target" reaction:
    target_emoji = unless config[:board_emoji] == "*"
      # If we're looking for a specific board emoji, search for it
      message.reactions.not_nil!.find { |element|
      Util.reaction_to_s(element.emoji) == config[:board_emoji]
    }.not_nil!
    else
      # Otherwise, take the one with the highest count
      message.reactions.not_nil!.sort { |element|
      element.count.to_i32
    }.first
    end
    # Extract representation from the target emoji
    count = target_emoji.count
    emoji_s = Util.reaction_to_s(target_emoji.emoji)
    return if count < config[:board_min_reacts]

    unless @@board_messages.has_key? payload.message_id
      begin
        posted_message = bot!.create_message(
          config[:board_channel],
          "",
          build_embed(guild, message, count, emoji_s)
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
        bot!.edit_message(
          config[:board_channel],
          @@board_messages[payload.message_id.to_u64],
          "",
          build_embed(guild, message, count, emoji_s)
        )
      rescue e
        Log.error("Failed to edit board message: #{e}")
      end
    end
  end

  # Helper for rendering the board post embed
  def build_embed(guild_id, message, count, emoji)
    ctx = Commands::GuildOnlyContext.new(guild_id: guild_id.to_u64)
    embed = Discord::Embed.new(
      timestamp: message.timestamp,
      author: Discord::EmbedAuthor.new(
        message.author.tag,
        nil,
        "https://cdn.discordapp.com/avatars/#{message.author.id}/#{message.author.avatar}"
      ),
      fields: [
        Discord::EmbedField.new(
          "Message",
          "#{count}x #{emoji} — Posted to <##{message.channel_id}> — [Jump](https://discordapp.com/channels/#{guild_id}/#{message.channel_id}/#{message.id})"
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
