module JoinLeaveLog
  extend self

  def handle_update(client, channel_id, user_id, out_string)
    out_string = out_string.gsub("@user", "<@#{user_id}>")
    client.create_message(channel_id, out_string)
  end

  def handle_join(payload)
    client = bot!
    return unless State.feature?(payload.guild_id, State::Features::JoinLog)
    config = State.get(payload.guild_id)
    handle_update(
      client, config[:join_channel], payload.user.id, config[:join_text]
    )
  end

  def handle_leave(payload)
    client = bot!
    return unless State.feature?(payload.guild_id, State::Features::LeaveLog)
    config = State.get(payload.guild_id)
    handle_update(
      client, config[:leave_channel], payload.user.id, config[:leave_text]
    )
  end

  Log.info("Loaded JoinLeaveLog Module")
end
