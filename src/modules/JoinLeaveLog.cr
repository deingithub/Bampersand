module JoinLeaveLog
  # This module posts messages to channels when users join or leave guilds.
  extend self

  def handle_join(payload)
    return unless Config.feature?(payload.guild_id, Config::Features::JoinLog)
    config = Config.get(payload.guild_id)
    out_string = config[:join_text].gsub("@user", "<@#{payload.user.id}>")
    BOT.create_message(config[:join_channel], out_string)
  end

  def handle_leave(payload)
    return unless Config.feature?(payload.guild_id, Config::Features::LeaveLog)
    config = Config.get(payload.guild_id)
    out_string = config[:leave_text].gsub("@user", "#{payload.user.tag} (`#{payload.user.id}`)")
    BOT.create_message(config[:leave_channel], out_string)
  end

  LOG.info("Loaded JoinLeaveLog Module")
end
