require "../modules/Commands"

macro macro_stop_feature(feature_enum)
  Arguments.assert_count(args, 1)
  guild = ctx.message.guild_id.not_nil!
  if args[0] == "stop"
    Config.feature(guild, Config::Features::{{feature_enum}}, false)
    next true
  end
end

Commands.register_command("config mirror", "Sets up the Mirroring feature.", Perms::Level::Operator) do |args, ctx|
  macro_stop_feature(Mirror)
  guild_id = ctx.message.guild_id.not_nil!
  channel = Arguments.at_position(args, 0, :channel)
  raise "Bad mirror target." if channel.id == ctx.message.channel_id

  Config.set(guild_id, {mirror_in: ctx.message.channel_id.to_u64, mirror_out: channel.id.to_u64})
  Config.feature(guild_id, Config::Features::Mirror, true)
  true
end

Commands.register_command("config board", "Sets up the Board Feature.", Perms::Level::Admin) do |args, ctx|
  macro_stop_feature(Board)
  Arguments.assert_count(args, 3)
  guild_id = Util.assert_guild(ctx)
  min_reacts = args[2].to_u32
  raise "min_reacts must be greater than zero." if min_reacts == 0

  Config.set(
    guild_id,
    {
      board_emoji:      args[0],
      board_channel:    Arguments.at_position(args, 1, :channel).id.to_u64,
      board_min_reacts: min_reacts,
    }
  )
  Config.feature(guild_id, Config::Features::Board, true)
  true
end

Commands.register_command("config join-log", "Sets up the JoinLog feature.", Perms::Level::Admin) do |args, ctx|
  macro_stop_feature(JoinLog)
  guild_id = Util.assert_guild(ctx)
  Arguments.assert_count(args, 2)
  channel = Arguments.at_position(args, 0, :channel)
  args.shift
  text = args.join(" ").strip

  Config.set(guild_id, {join_channel: channel.id.to_u64, join_text: text})
  Config.feature(guild_id, Config::Features::JoinLog, true)
  true
end

Commands.register_command("config leave-log", "Sets up the LeaveLog Feature.", Perms::Level::Admin) do |args, ctx|
  macro_stop_feature(LeaveLog)
  guild_id = Util.assert_guild(ctx)
  Arguments.assert_count(args, 2)
  channel = Arguments.at_position(args, 0, :channel)
  args.shift
  text = args.join(" ").strip

  Config.feature(guild_id, Config::Features::LeaveLog, true)
  Config.set(guild_id, {leave_channel: channel.id.to_u64, leave_text: text})
  true
end

Commands.register_command("config slowmode", "Enforces slowmode in the current channel for everyone.", Perms::Level::Admin) do |args, ctx|
  guild_id = Util.assert_guild(ctx)
  Arguments.assert_count(args, 1)
  if args[0].downcase == "stop"
    ModTools.remove_channel_slowmode(ctx.message.channel_id)
  else
    secs = args[0].to_u32
    ModTools.set_channel_slowmode(ctx.message.channel_id, secs)
  end
  true
end

Commands.register_command("config mod-role", "Sets the Moderator Level role.", Perms::Level::Admin) do |args, ctx|
  guild_id = Util.assert_guild(ctx)
  role = Arguments.at_position(args, 0, :role)
  Perms.update_perms(guild_id, Perms::Level::Moderator, role.id.to_u64)
  true
end

Commands.register_command("config admin-role", "Sets the Admin Level role.", Perms::Level::Owner) do |args, ctx|
  guild_id = Util.assert_guild(ctx)
  role = Arguments.at_position(args, 0, :role)
  Perms.update_perms(guild_id, Perms::Level::Admin, role.id.to_u64)
  true
end

Commands.register_command("config print", "Stringifies the configuration.", Perms::Level::Admin) do |_args, ctx|
  "```#{Config.get(ctx.message.guild_id)}```"
end

Commands.register_command("config", "[Edit per-guild configuration]", Perms::Level::Admin) do
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
