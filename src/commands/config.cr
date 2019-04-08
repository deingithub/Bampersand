require "../Commands"
require "../Util"
require "../Arguments"

module CommandsConfig
  include Commands
  HELP = {
    text: "| config mirror <#channel | stop>
    | config board <emoji #channel min_reacts | stop>
    | config join-log <#channel welcome @user! some more text here. | stop>
    | config leave-log <#channel @user left. more text. | stop>
    | config print",
    title: "**BAMPERSAND CONFIGURATION**",
  }

  macro check_stop(feature_enum, feature_name)
    if args[0] == "stop"
      State.feature(guild, State::Features::{{feature_enum}}, false)
      return "Disabled #{{{feature_name}}}."
    end
  end

  CONFIG = ->(args : Array(String), ctx : CommandContext) {
    return HELP if args.size == 0
    raise "This command can only be used in guilds" if ctx[:guild_id].nil?
    Util.assert_perms(ctx, ManageGuild)
    guild = ctx[:guild_id].as(UInt64)
    subcommand = args.shift.downcase
    return case subcommand
    when "print"
      "```#{State.get(guild).to_s}```"
    when "mirror"
      Arguments.assert_count(args, 1)
      check_stop(Mirror, "mirroring")
      raise "Command restricted to bot operator." unless ctx[:issuer].id == Bampersand::CONFIG["admin"].to_u64
      channel = Arguments.at_position(args, 0, :channel)
      raise "You can't mirror a channel into itself" if channel.id == ctx[:channel_id]
      State.set(guild, {mirror_in: ctx[:channel_id], mirror_out: channel.id.to_u64})
      State.feature(guild, State::Features::Mirror, true)
      "Mirroring to <##{channel.id}>.
			Issue `config mirror stop` to disable."
    when "board"
      Arguments.assert_count(args, 1)
      check_stop(Board, "board")
      Arguments.assert_count(args, 3)
      emoji = args[0]
      channel = Arguments.at_position(args, 1, :channel)
      min_reacts = args[2].to_u32
      raise "min_reacts must be greater than zero" if min_reacts == 0
      State.set(
        guild,
        {
          board_emoji:      emoji,
          board_channel:    channel.id.to_u64,
          board_min_reacts: min_reacts,
        }
      )
      State.feature(guild, State::Features::Board, true)
      "All messages with #{min_reacts} or more #{emoji} reactions will be posted to <##{channel.id}>.
      Issue `config board stop` to disable."
    when "join-log"
      Arguments.assert_count(args, 1)
      check_stop(JoinLog, "join log")
      channel = Arguments.at_position(args, 0, :channel)
      args.shift
      text = args.join(" ").strip
      raise "Missing join message" if text.size == 0
      State.feature(guild, State::Features::JoinLog, true)
      State.set(guild, {join_channel: channel.id.to_u64, join_text: text})
      "New members will be greeted in <##{channel.id}>."
    when "leave-log"
      Arguments.assert_count(args, 1)
      check_stop(LeaveLog, "leave log")
      channel = Arguments.at_position(args, 0, :channel)
      args.shift
      text = args.join(" ").strip
      raise "Missing leave message" if text.size == 0
      State.feature(guild, State::Features::LeaveLog, true)
      State.set(guild, {leave_channel: channel.id.to_u64, leave_text: text})
      "Departures will be announced in <##{channel.id}>."
    else
      raise "Unknown subcommand"
    end
  }
end
