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

  VERSION   = "0.8.2"
  PRESENCES = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "the heat death of the universe", "[ASMR] Richard Stallman tells you to use free software", "the decline of western civilisation", "4'33'' (Nightcore Remix)", "General Protection Fault", "breadtube", "the book of origin"]
  STARTUP   = Time.monotonic
  DATABASE  = DB.open "sqlite3://./bampersand.sqlite3"
  CONFIG    = Dotenv.load!

  def start
    client = Discord::Client.new(
      token: "Bot #{CONFIG["token"]}",
      client_id: CONFIG["client"].to_u64
    )
    client.cache = Discord::Cache.new(client)

    client.on_message_create do |msg|
      Mirroring.handle_message(client, msg)
      Commands.handle_message(client, msg) unless msg.author.bot
    end

    client.on_ready do |payload|
      client.status_update(
        "online",
        Discord::GamePlaying.new(name: PRESENCES.sample, type: 2i64)
      )
    end

    client.on_message_reaction_add do |payload|
      Board.handle_reaction(client, payload)
    end

    client.on_guild_create do |payload|
      Log.info("Joined new guild #{payload.name} — Owner is #{payload.owner_id}")
    end

    client.on_guild_member_add do |payload|
      JoinLeaveLog.handle_join(client, payload)
    end

    client.on_guild_member_remove do |payload|
      JoinLeaveLog.handle_leave(client, payload)
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
