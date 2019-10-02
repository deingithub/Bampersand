module Board
  # This module handles the reaction based best-of tracker.
  extend self

  # Maps source Message ID => Board Message ID
  @@board_messages : Hash(UInt64, UInt64) = ->{
    board_data = {} of UInt64 => UInt64
    DATABASE.query(
      "select source_message, board_message from board"
    ) do |rs|
      rs.each do
        board_data[rs.read(Int64).to_u64] = rs.read(Int64).to_u64
      end
    end
    LOG.info("Loaded Board Module: #{board_data.size} stored board messages")
    board_data
  }.call

  # The event handler calls this.
  def handle_reaction_add(payload)
    guild = Util.guild(BOT, payload.channel_id)
    return unless guild && Config.feature? guild, Config::Features::Board
    guild_config = Config.get(guild)
    return if payload.channel_id.to_u64 == guild_config[:board_channel]
    return unless Util.reaction_to_s(payload.emoji) == guild_config[:board_emoji] || guild_config[:board_emoji] == "*"
    message = BOT.get_channel_message(payload.channel_id, payload.message_id)
    # Get the "target" reaction:
    target_emoji = if guild_config[:board_emoji] == "*"
                     # If we don't have a target emoji, take the one with the highest count
                     message.reactions.not_nil!.sort { |element|
                       element.count.to_i32
                     }.first
                   else
                     # otherwise, we're looking for a specific board emoji, search for it
                     message.reactions.not_nil!.find { |element|
                       Util.reaction_to_s(element.emoji) == guild_config[:board_emoji]
                     }.not_nil!
                   end
    # Extract representation from the target emoji
    count = target_emoji.count
    emoji_s = Util.reaction_to_s(target_emoji.emoji)
    return if count < guild_config[:board_min_reacts]

    if @@board_messages.has_key? payload.message_id
      begin
        BOT.edit_message(
          guild_config[:board_channel],
          @@board_messages[payload.message_id.to_u64],
          "",
          build_embed(guild, message, count, emoji_s)
        )
      rescue e
        LOG.error("Failed to edit board message: #{e}")
      end
    else
      begin
        posted_message = BOT.create_message(
          guild_config[:board_channel],
          "",
          build_embed(guild, message, count, emoji_s)
        )
        @@board_messages[payload.message_id.to_u64] = posted_message.id.to_u64
        DATABASE.exec(
          "insert into board (source_message, board_message) values (?,?)",
          payload.message_id.to_i64,
          posted_message.id.to_i64
        )
      rescue e
        LOG.error("Failed to post board message: #{e}")
      end
    end
  end

  # Helper for rendering the board post embed
  def build_embed(guild_id, message, count, emoji)
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
