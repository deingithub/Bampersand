require "db"
require "discordcr"
require "dotenv"
require "logger"
require "sqlite3"

require "./Commands"
require "./Mirroring"
require "./Board"
require "./Util"
require "./State"
require "./JoinLeaveLog"

module Bampersand
  extend self
  include Commands

  VERSION   = `shards version`.chomp
  PRESENCES = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "the heat death of the universe", "[ASMR] Richard Stallman tells you to use free software", "the decline of western civilisation", "4'33'' (Nightcore Remix)", "General Protection Fault", "breadtube", "the book of origin"]
  STARTUP   = Time.monotonic
  DATABASE  = DB.open "sqlite3://./bampersand.sqlite3"
  CONFIG    = Dotenv.load!
  CLIENT    = load_client

  def load_client
    client = Discord::Client.new(
      token: "Bot #{CONFIG["token"]}",
      client_id: CONFIG["client"].to_u64
    )
    client.cache = Discord::Cache.new(client)
    client
  end

  def start
    client = CLIENT
    client.on_message_create do |msg|
      Mirroring.handle_message(msg)
      Commands.handle_message(msg) unless msg.author.bot
    end

    client.on_ready do |payload|
      if CONFIG["runas"] == "prod"
        client.status_update(
          "online",
          Discord::GamePlaying.new(name: PRESENCES.sample, type: 2i64)
        )
      elsif CONFIG["runas"] == "dev"
        client.status_update(
          "online",
          Discord::GamePlaying.new(name: VERSION.to_s, type: 0i64)
        )
      else
        raise "Invalid run-as environment #{CONFIG["runas"]}"
      end
    end

    client.on_message_reaction_add do |payload|
      Board.handle_reaction(payload)
    end

    client.on_guild_create do |payload|
      Log.info("Joined new guild #{payload.name} — Owner is #{payload.owner_id}")
    end

    client.on_guild_member_add do |payload|
      JoinLeaveLog.handle_join(payload)
    end

    client.on_guild_member_remove do |payload|
      JoinLeaveLog.handle_leave(payload)
    end

    client.run
  end
end

SHUTDOWN = ->(s : Signal) {
  Log.fatal "Received #{s}"
  Bampersand::DATABASE.close
  Log.fatal "This program is halting now, checkmate Alan"
  exit 0
}
Signal::INT.trap &SHUTDOWN
Signal::TERM.trap &SHUTDOWN

Log = Logger.new(STDOUT, level: Logger::INFO, progname: "B&")
Bampersand.start
