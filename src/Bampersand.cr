require "ini"
require "discordcr"
require "logger"
require "./Commands"
require "./Config"
require "./Mirroring"
require "./Board"
require "./Util"

module Bampersand
	extend self
	include Commands

  VERSION = "0.5.0"
	PRESENCES = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "fading memories"]
	STARTUP = Time.monotonic
	@@GUILD_COUNT = 0u32
	def guild_count
		@@GUILD_COUNT
	end

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
			@@GUILD_COUNT += 1
		end
		client.run
	end
end

Log = Logger.new(STDOUT, level: Logger::INFO, progname: "Bampersand")
Bampersand.start
