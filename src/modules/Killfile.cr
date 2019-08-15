module Killfile
  # This module handles guildwide self-blocks.
  extend self

  @@killfile : Array(UInt64) = ->{
    killfile = [] of UInt64
    DATABASE.query "select * from killfile" do |rs|
      rs.each do
        killfile += [rs.read(Int64).to_u64]
      end
    end
    killfile
  }.call

  def handle_join(payload)
    if @@killfile.includes? payload.id.to_u64
      BOT.leave_guild(payload.id)
      LOG.info("Guild #{payload.id} is in killfile, leaving again.")
    end
  end

  def add_to_killfile(guild_id)
    LOG.info("Adding guild #{guild_id} to killfile.")
    @@killfile << guild_id
    DATABASE.exec "insert into killfile (guild_id) values (?)", guild_id.to_i64
    channels = CACHE.channels.values.select { |channel|
      (channel.guild_id || 0).to_u64 == guild_id
    }
    send_success = false
    channels.each do |channel|
      next if send_success
      begin
        BOT.create_message(channel.id, "The Bot operator is no longer comfortable with you using their services. This decision is final. Have a nice day.")
        send_success = true
      rescue e
      end
    end
    LOG.info("Sent goodbye message to #{guild_id}") if send_success
    BOT.leave_guild(guild_id)
    LOG.info("Left guild #{guild_id}.")
  end

  LOG.info("Loaded Killfile Module, blocking #{@@killfile.size} guilds.")
end
