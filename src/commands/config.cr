CONFIG_HELP = {
  text: "| config mirror <#channel | stop>
  | config board <emoji #channel min_reacts | stop>
  | config join-log <#channel welcome @user! some more text here. | stop>
  | config leave-log <#channel @user left. more text. | stop>
  | config slowmode <secs | stop>
  | config print",
  title: "**BAMPERSAND CONFIGURATION**",
}

macro check_stop(feature_enum)
  if args[0] == "stop"
    State.feature(guild, State::Features::{{feature_enum}}, false)
    next true
  end
end

Commands.register_command("config") do |args, ctx|
  next CONFIG_HELP if args.size == 0
  Perms.assert_level(Admin)
  guild = ctx.guild_id.not_nil!
  subcommand = args.shift.downcase
  next case subcommand
  when "print"
    "```#{State.get(guild).to_s}```"
  when "mirror"
    Arguments.assert_count(args, 1)
    check_stop(Mirror)
    Perms.assert_level(Operator)
    channel = Arguments.at_position(args, 0, :channel)
    raise "Bad mirror target." if channel.id == ctx.channel_id
    State.set(guild, {mirror_in: ctx.channel_id, mirror_out: channel.id.to_u64})
    State.feature(guild, State::Features::Mirror, true)
    true
  when "board"
    Arguments.assert_count(args, 1)
    check_stop(Board)
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
  when "join-log"
    Arguments.assert_count(args, 2)
    check_stop(JoinLog)
    channel = Arguments.at_position(args, 0, :channel)
    args.shift
    text = args.join(" ").strip
    State.feature(guild, State::Features::JoinLog, true)
    State.set(guild, {join_channel: channel.id.to_u64, join_text: text})
    true
  when "leave-log"
    Arguments.assert_count(args, 2)
    check_stop(LeaveLog)
    channel = Arguments.at_position(args, 0, :channel)
    args.shift
    text = args.join(" ").strip
    State.feature(guild, State::Features::LeaveLog, true)
    State.set(guild, {leave_channel: channel.id.to_u64, leave_text: text})
    true
  when "slowmode"
    Arguments.assert_count(args, 1)
    if args[0].downcase == "stop"
      ModTools.remove_channel_slowmode(ctx.channel_id)
      next true
    end
    secs = args[0].to_u32
    ModTools.set_channel_slowmode(ctx.channel_id, secs)
    true
  when "mod-role"
    role = Arguments.at_position(args, 0, :role)
    Perms.update_perms(guild, Perms::Level::Moderator, role.id.to_u64)
    true
  when "admin-role"
    Perms.assert_level(Owner)
    role = Arguments.at_position(args, 0, :role)
    Perms.update_perms(guild, Perms::Level::Admin, role.id.to_u64)
    true
  else
    raise "Unknown subcommand."
  end
end
