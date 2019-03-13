require "ini"
require "discordcr"
require "logger"
require "./Commands"
require "./Config"
require "./Mirroring"
require "./Board"

module Bampersand
	extend self
	include Commands

  VERSION = "0.2.0"

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
			next if msg.author.bot
			Commands.handle_message(client, msg)
		end
		client.on_ready do |payload|
			client.status_update(
				"online",
				Discord::GamePlaying.new(name: "your concerns", type: 2i64)
			)
		end
		client.on_message_reaction_add do |payload|
			Board.handle_reaction(client, payload)
		end
		client.run
	end
end

Log = Logger.new(STDOUT, level: Logger::INFO, progname: "Bampersand")
Bampersand.start
