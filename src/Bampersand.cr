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
require "./ModTools"
require "./Perms"

module Discord::REST
  # Changes the position of roles. Requires the "Manage Roles" permission
  # and you cannot raise roles above the bot's highest role.
  #
  # [API docs for this method](https://discordapp.com/developers/docs/resources/guild#modify-guild-role-positions)
  def modify_guild_role_positions(guild_id : UInt64 | Snowflake,
                                  positions : Array(ModifyRolePositionPayload))
    response = request(
      :guilds_gid_roles,
      guild_id,
      "PATCH",
      "/guilds/#{guild_id}/roles",
      HTTP::Headers{"Content-Type" => "application/json"},
      positions.to_json
    )

    Array(Role).from_json(response.body)
  end

  struct ModifyRolePositionPayload
    JSON.mapping(
      id: Snowflake,
      position: Int32
    )

    def initialize(id : UInt64 | Snowflake, @position : Int32)
      id = Snowflake.new(id) unless id.is_a?(Snowflake)
      @id = id
    end
  end
end

module Bampersand
  extend self
  include Commands

  VERSION   = `shards version`.chomp
  PRESENCES = ["your concerns", "endless complaints", "socialist teachings", "the silence of the lambs", "anarchist teachings", "emo poetry", "FREUDE SCHÖNER GÖTTERFUNKEN", "the heat death of the universe", "[ASMR] Richard Stallman tells you to use free software", "the decline of western civilisation", "4'33'' (Nightcore Remix)", "General Protection Fault", "breadtube", "the book of origin"]
  STARTUP   = Time.monotonic
  DATABASE  = DB.open "sqlite3://./bampersand.sqlite3"
  CONFIG    = Dotenv.load!
  CLIENT    = load_client
  CACHE     = CLIENT.cache.not_nil!

  def load_client
    client = Discord::Client.new(token: "Bot #{CONFIG["token"]}")
    client.cache = Discord::Cache.new(client)
    client
  end

  def start
    client = CLIENT
    client.on_message_create do |msg|
      ModTools.enforce_slowmode(msg)
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

Log = Logger.new(STDOUT, level: Logger::DEBUG, progname: "B&")
Log.info("Loaded Bampersand v#{Bampersand::VERSION}")
Log.info("WHAT ARE YOUR COMMANDS?")
Bampersand.start
