require "../Commands"
require "../Util"

module CommandsConfig
	include Commands
	CONFIG = ->(args: Array(String), ctx: CommandContext) {
		if args.size == 0
			return <<-STR
			| config mirror <#channel | halt>
			| config board <emoji #channel min_reacts | halt>
			| config print
			STR
		end

		raise "This command can only be used in guilds" if ctx[:guild_id].nil?
		raise "Insufficient Permissions" unless Util.perms?(
			ctx[:client],
			ctx[:issuer].id,
			ctx[:guild_id].as(UInt64),
			Discord::Permissions::ManageGuild
		)

		return case args[0]
		when "print"
			Config.s?(ctx[:guild_id]) ? Config.s(ctx[:guild_id]).to_s : "No state stored for this guild"
		when "mirror"
			raise "Missing argument" unless args.size == 2
			if args[1] == "halt"
				Config.mod_s(ctx[:guild_id].as(UInt64), {f_mirroring: false})
				return "Stopped mirroring."
			end
			channel = Util.channel(ctx[:client], args[1])
			raise "Invalid channel" if channel.nil?
			raise "You can't mirror a channel into itself" if channel.id == ctx[:channel_id]
			Config.mod_s(
				ctx[:guild_id].as(UInt64),
				{
					f_mirroring: true,
					in_channel: ctx[:channel_id],
					out_channel: channel.id.to_u64
				}
			)
			"Mirroring to <##{channel.id}>"
	when "board"
		raise "Missing arguments" unless args.size > 1
		if args[1] == "halt"
			Config.mod_s(ctx[:guild_id].as(UInt64), {f_board: false})
			return "Disabled board."
		end
		raise "Invalid arguments" unless args.size == 4
		emoji = args[1]
		raise "Invalid Emoji" unless emoji == "⭐"
		channel = Util.channel(ctx[:client], args[2])
		raise "Invalid Channel" if channel.nil?
		min_reacts = args[3].to_u64
		raise "Zero is too low." if min_reacts == 0
		Config.mod_s(
			ctx[:guild_id].as(UInt64),
			{
				f_board: true,
				board_emoji: emoji,
				board_channel: channel.id.to_u64,
				board_min_reacts: min_reacts
			}
		)
		"Noted."
	else
		raise "Unknown subcommand"
	end
}
end
