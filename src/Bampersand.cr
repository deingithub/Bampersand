require "db"
require "discordcr"
require "ini"
require "logger"
require "sqlite3"

require "./Commands"
require "./Config"
require "./Mirroring"
require "./Board"
require "./Util"

module Bampersand
	extend self
	include Commands

  VERSION = "0.5.4"
	PRESENCES = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "the heat death of the universe", "[ASMR] Richard Stallman tells you to use free software", "the decline of western civilisation", "4'33'' (Nightcore Remix)", "General Protection Fault", "breadtube", "the book of origin"]
	STARTUP = Time.monotonic
	DATABASE = DB.open "sqlite3://./bampersand.sqlite3"

	def load_client(config)
		client = Discord::Client.new(token: "Bot #{config["token"]}", client_id: config["client"].to_u64)
		cache = Discord::Cache.new(client)
		client.cache = cache
		client
	end

	def start()
		client = load_client(Config.f)
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
