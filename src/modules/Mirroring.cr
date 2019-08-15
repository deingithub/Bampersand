module Mirroring
  # This module mirrors all messages from certain channels to others.
  # DANGEROUS!
  # Can lead to looping messages (and ratelimit violations and suspensions)
  # Setting it up is therefore restricted to the bot operator.
  extend self

  # The event handler calls this.
  def handle_message(msg)
    client = BOT
    guild = msg.guild_id
    return unless Config.feature? guild, Config::Features::Mirror
    return unless msg.channel_id == Config.get(guild)[:mirror_in]
    begin
      client.create_message(
        Config.get(guild)[:mirror_out], "", embed: format_message(msg)
      )
    rescue e
      LOG.error "Failed to mirror message #{msg.id}: #{e}"
    end
  end

  # Renders message to discord
  def format_message(msg)
    embed = Discord::Embed.new(
      title: "#{msg.author.tag} (#{msg.author.id})",
      timestamp: msg.timestamp
    )
    if msg.content.size > 0
      embed.description = msg.content
    end
    if msg.attachments.size == 1
      embed.image = Discord::EmbedImage.new(msg.attachments[0].url)
    end
    embed
  end

  LOG.info("Loaded Mirroring Module")
end
