# This is the code necessary for connecting to Discord.
# The binary's entry point is in Init.cr.

require "discordcr"
require "./DiscordCrAddenda"

require "./Util"
require "./Arguments"
require "./Perms"

require "./modules/Config"
require "./modules/Mirroring"
require "./modules/Board"
require "./modules/JoinLeaveLog"
require "./modules/ModTools"
require "./modules/Killfile"
require "./modules/RoleKiosk"
require "./modules/Commands"

require "./commands/*"

module Bampersand
  def self.boot
    # Prepare connection to Discord
    client = Discord::Client.new(token: "Bot #{ENV["token"]}")
    client.cache = Discord::Cache.new(client)

    # Set up event handlers
    client.on_message_create do |msg|
      ModTools.enforce_slowmode(msg)
      Mirroring.handle_message(msg)
      Commands.handle_message(msg) unless msg.author.bot
    end
    client.on_ready do
      presences = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "the heat death of the universe", "[ASMR] Richard Stallman tells you to use free software", "the decline of western civilisation", "4'33'' (Nightcore Remix)", "General Protection Fault", "breadtube", "the book of origin"]
      if ENV["runas"] == "prod"
        client.status_update(
          "online",
          Discord::GamePlaying.new(name: presences.sample, type: 2i64)
        )
      elsif ENV["runas"] == "dev"
        client.status_update(
          "online",
          Discord::GamePlaying.new(name: VERSION.to_s, type: 3i64)
        )
      else
        raise "Invalid environment #{ENV["runas"]}"
      end
    end
    client.on_message_reaction_add do |payload|
      RoleKiosk.handle_reaction_add(payload)
      Board.handle_reaction_add(payload)
    end
    client.on_message_reaction_remove do |payload|
      RoleKiosk.handle_reaction_remove(payload)
    end
    client.on_guild_create do |payload|
      LOG.info(
        "Joined new guild #{payload.name} [#{payload.id}] — Owner is #{payload.owner_id}"
      )
      Killfile.handle_join(payload)
    end
    client.on_guild_member_add do |payload|
      JoinLeaveLog.handle_join(payload)
    end
    client.on_guild_member_remove do |payload|
      JoinLeaveLog.handle_leave(payload)
    end

    LOG.info("Loaded Bampersand v#{VERSION}")
    LOG.info("WHAT ARE YOUR COMMANDS?")
    client
  end
end
