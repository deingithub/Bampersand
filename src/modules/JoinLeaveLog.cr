module JoinLeaveLog
  # This module posts messages to channels when users join or leave guilds.
  extend self

  # The event handler calls this, actual lifting is done in #handle_update
  def handle_join(payload)
    return unless State.feature?(payload.guild_id, State::Features::JoinLog)
    config = State.get(payload.guild_id)
    handle_update(config[:join_channel], payload.user.id, config[:join_text])
  end

  # The event handler calls this, actual lifting is done in #handle_update
  def handle_leave(payload)
    return unless State.feature?(payload.guild_id, State::Features::LeaveLog)
    config = State.get(payload.guild_id)
    handle_update(config[:leave_channel], payload.user.id, config[:leave_text])
  end

  # Renders message to discord
  def handle_update(channel_id, user_id, out_string)
    out_string = out_string.gsub("@user", "<@#{user_id}>")
    bot!.create_message(channel_id, out_string)
  end

  Log.info("Loaded JoinLeaveLog Module")
end
