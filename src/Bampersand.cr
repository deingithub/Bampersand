# This is the main code for initializing the bot client and

require "db"
require "discordcr"
require "dotenv"
require "logger"
require "sqlite3"

# Fix for modify_guild_role_positions until it's merged into their master
require "./DiscordCr"

# This makes the client and its cache globally available. It's ugly
# but shorter than writing Bampersand.client.not_nil!.whatever
macro bot!
  Bampersand.client.not_nil!
end

macro cache!
  Bampersand.cache.not_nil!
end

require "./Util"
require "./State"
require "./Arguments"
require "./Perms"

require "./modules/Mirroring"
require "./modules/Board"
require "./modules/JoinLeaveLog"
require "./modules/ModTools"
require "./modules/Killfile"
require "./modules/Commands"

module Bampersand
  VERSION   = `shards version`.chomp
  PRESENCES = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "the heat death of the universe", "[ASMR] Richard Stallman tells you to use free software", "the decline of western civilisation", "4'33'' (Nightcore Remix)", "General Protection Fault", "breadtube", "the book of origin"]
  STARTUP   = Time.monotonic
  DATABASE  = DB.open "sqlite3://./bampersand.sqlite3"

  # Needs to be nilable as we don't want to connect to discord when running
  # tests, so the client init is in a method which isn't guaranteed to run
  @@bot : Discord::Client?
  @@cache : Discord::Cache?

  # Don't use these, but the bot! and cache! macros instead
  def self.client
    @@bot
  end

  def self.cache
    @@cache
  end

  # Entry method for booting the bot
  def self.start
    # Prepare connection to Discord
    client = Discord::Client.new(token: "Bot #{ENV["token"]}")
    client.cache = Discord::Cache.new(client)
    @@bot = client
    @@cache = @@bot.not_nil!.cache.not_nil!

    # Set up event handlers
    bot!.on_message_create do |msg|
      ModTools.enforce_slowmode(msg)
      Mirroring.handle_message(msg)
      Commands.handle_message(msg) unless msg.author.bot
    end
    bot!.on_ready do
      if ENV["runas"] == "prod"
        bot!.status_update(
          "online",
          Discord::GamePlaying.new(name: PRESENCES.sample, type: 2i64)
        )
      elsif ENV["runas"] == "dev"
        bot!.status_update(
          "online",
          Discord::GamePlaying.new(name: VERSION.to_s, type: 3i64)
        )
      else
        raise "Invalid run-as environment #{ENV["runas"]}"
      end
    end
    bot!.on_message_reaction_add do |payload|
      Board.handle_reaction(payload)
    end
    bot!.on_guild_create do |payload|
      LOG.info(
        "Joined new guild #{payload.name} [#{payload.id}] — Owner is #{payload.owner_id}"
      )
      Killfile.handle_join(payload)
    end
    bot!.on_guild_member_add do |payload|
      JoinLeaveLog.handle_join(payload)
    end
    bot!.on_guild_member_remove do |payload|
      JoinLeaveLog.handle_leave(payload)
    end

    LOG.info("Loaded Bampersand v#{Bampersand::VERSION}")
    LOG.info("WHAT ARE YOUR COMMANDS?")
    # Then, by all means, let there be … life!
    bot!.run
  end
end
