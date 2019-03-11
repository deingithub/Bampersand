require "ini"
require "discordcr"
require "logger"
require "./Commands"

module Bampersand
	extend self
	include Commands

  VERSION = "0.1.0"

	def load_config(path)
		INI.parse(File.read(path))["config"]
	end

	def load_client(config)
		Discord::Client.new(token: "Bot #{config["token"]}", client_id: config["client"].to_u64)
	end

	def start()
		cfg = load_config("config.ini")
		client = load_client(cfg)
		client.on_message_create do |msg|
			next if msg.author.bot
			Commands.handle_message(client, cfg, msg)
		end
		client.run
	end
end

LOG = Logger.new(STDOUT, level: Logger::INFO, progname: "Bampersand")
Bampersand.start
