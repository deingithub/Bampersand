macro common(feature_enum)
  Arguments.assert_count(args, 1)
  guild = ctx.guild_id.not_nil!
  if args[0] == "stop"
    State.feature(guild, State::Features::{{feature_enum}}, false)
    next true
  end
end

Commands.register_command("config mirror") do |args, ctx|
  common(Mirror)
  guild = ctx.guild_id.not_nil!
  channel = Arguments.at_position(args, 0, :channel)
  raise "Bad mirror target." if channel.id == ctx.channel_id
  State.set(guild, {mirror_in: ctx.channel_id, mirror_out: channel.id.to_u64})
  State.feature(guild, State::Features::Mirror, true)
  true
end

Commands.register_command("config board") do |args, ctx|
  common(Board)
  guild = ctx.guild_id.not_nil!
  Arguments.assert_count(args, 3)
  emoji = args[0]
  channel = Arguments.at_position(args, 1, :channel)
  min_reacts = args[2].to_u32
  raise "min_reacts must be greater than zero." if min_reacts == 0
  State.set(
    guild,
    {
      board_emoji:      emoji,
      board_channel:    channel.id.to_u64,
      board_min_reacts: min_reacts,
    }
  )
  State.feature(guild, State::Features::Board, true)
  true
end

Commands.register_command("config join-log") do |args, ctx|
  common(JoinLog)
  guild = ctx.guild_id.not_nil!
  Arguments.assert_count(args, 2)
  channel = Arguments.at_position(args, 0, :channel)
  args.shift
  text = args.join(" ").strip
  State.feature(guild, State::Features::JoinLog, true)
  State.set(guild, {join_channel: channel.id.to_u64, join_text: text})
  true
end

Commands.register_command("config leave-log") do |args, ctx|
  common(LeaveLog)
  guild = ctx.guild_id.not_nil!
  Arguments.assert_count(args, 2)
  channel = Arguments.at_position(args, 0, :channel)
  args.shift
  text = args.join(" ").strip
  State.feature(guild, State::Features::LeaveLog, true)
  State.set(guild, {leave_channel: channel.id.to_u64, leave_text: text})
  true
end

Commands.register_command("config slowmode") do |args, ctx|
  guild = ctx.guild_id.not_nil!
  Arguments.assert_count(args, 1)
  if args[0].downcase == "stop"
    ModTools.remove_channel_slowmode(ctx.channel_id)
    next true
  end
  secs = args[0].to_u32
  ModTools.set_channel_slowmode(ctx.channel_id, secs)
  true
end

Commands.register_command("config mod-role") do |args, ctx|
  guild = ctx.guild_id.not_nil!
  role = Arguments.at_position(args, 0, :role)
  Perms.update_perms(guild, Perms::Level::Moderator, role.id.to_u64)
  true
end

Commands.register_command("config admin-role") do |args, ctx|
  guild = ctx.guild_id.not_nil!
  role = Arguments.at_position(args, 0, :role)
  Perms.update_perms(guild, Perms::Level::Admin, role.id.to_u64)
  true
end

Commands.register_command("config") do |args, ctx|
  {
    text: "| config mirror <#channel | stop>
  | config board <emoji #channel min_reacts | stop>
  | config join-log <#channel welcome @user! some more text here. | stop>
  | config leave-log <#channel @user left. more text. | stop>
  | config slowmode <secs | stop>
  | config print",
    title: "**BAMPERSAND CONFIGURATION**",
  }
end
