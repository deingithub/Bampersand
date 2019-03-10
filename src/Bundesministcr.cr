require "ini"
require "discordcr"
require "logger"
require "./Commands"

module Bundesministcr
	extend self
	include BundesministcrCommands

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
			next unless msg.content.starts_with?(cfg["prefix"])
			content = msg.content.lchop(cfg["prefix"])
			arguments = content.split(" ")
			command = arguments.shift
			next unless COMMANDS_AND_WHERE_TO_FIND_THEM[command]?
			output = ""
			begin
				LOG.info "#{msg.author.username}##{msg.author.discriminator} issued #{command} #{arguments}"
				output = COMMANDS_AND_WHERE_TO_FIND_THEM[command][:fun].call(
					arguments,
					contextualize(msg)
				)
			rescue e
				output = ":x: Error executing command."
				LOG.error e
			end
			client.create_message(msg.channel_id, output)
		end
		client.run
	end
end

LOG = Logger.new(STDOUT, level: Logger::INFO, progname: "Bundesministcr")
Bundesministcr.start
