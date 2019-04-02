require "../Commands"
require "../Util"

module CommandsConfig
  include Commands
  CONFIG = ->(args : Array(String), ctx : CommandContext) {
    return "**BAMPERSAND CONFIGURATION**
    | config mirror <#channel | stop>
    | config board <emoji #channel min_reacts | stop>
    | config join-log <#channel welcome @user! some more text here. | stop>
    | config leave-log <#channel @user left. more text. | stop>
    | config print" if args.size == 0

    raise "This command can only be used in guilds" if ctx[:guild_id].nil?
    guild = ctx[:guild_id].as(UInt64)
    raise "Insufficient Permissions" unless Util.perms?(ctx[:client], ctx[:issuer].id, guild, Discord::Permissions::ManageGuild)

    return case args[0]
    when "print"
      "```#{State.get(guild).to_s}```"
    when "mirror"
      raise "Missing target channel" unless args.size == 2
      if args[1] == "stop"
        State.feature(guild, State::Features::Mirror, false)
        return "Disabled mirroring."
      end
      raise "Command restricted to admin." unless ctx[:issuer].id == Bampersand::CONFIG[:admin]
      channel = Util.channel(ctx[:client], args[1])
      raise "Invalid channel" if channel.nil?
      raise "You can't mirror a channel into itself" if channel.id == ctx[:channel_id]
      State.set(guild, {mirror_in: ctx[:channel_id], mirror_out: channel.id.to_u64})
      State.feature(guild, State::Features::Mirror, true)
      return "Mirroring to <##{channel.id}>.
			Issue `config mirror stop` to disable."
    when "board"
      raise "Missing arguments" unless args.size > 1
      if args[1] == "stop"
        State.feature(guild, State::Features::Board, false)
        return "Disabled board."
      end
      raise "Invalid arguments" unless args.size == 4
      emoji = args[1]
      channel = Util.channel(ctx[:client], args[2])
      raise "Invalid Channel" if channel.nil?
      min_reacts = args[3].to_u32
      raise "Zero is too low." if min_reacts == 0
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
      raise "Missing arguments" unless args.size > 1
      if args[1] == "stop"
        State.feature(guild, State::Features::JoinLog, false)
        return "Disabled join log."
      end
      args.shift
      channel = Util.channel(ctx[:client], args.shift)
      raise "Invalid channel" if channel.nil?
      text = args.join(" ")
      State.feature(guild, State::Features::JoinLog, true)
      State.set(guild, {join_channel: channel.id.to_u64, join_text: text})
      "New members will be greeted in <##{channel.id}>."
    when "leave-log"
      raise "Missing arguments" unless args.size > 1
      if args[1] == "stop"
        State.feature(guild, State::Features::LeaveLog, false)
        return "Disabled leave log."
      end
      args.shift
      channel = Util.channel(ctx[:client], args.shift)
      raise "Invalid channel" if channel.nil?
      text = args.join(" ")
      State.feature(guild, State::Features::LeaveLog, true)
      State.set(guild, {leave_channel: channel.id.to_u64, leave_text: text})
      "Departures will be announced in <##{channel.id}>."
    else
      raise "Unknown subcommand"
    end
  }
end
