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
			raise "Invalid arguments" unless args.size == 2
			if args[1] == "halt"
				Config.mod_s(ctx[:guild_id].as(UInt64), {f_mirroring: false})
				"Stopped mirroring."
			else
				channel = Util.channel(ctx[:client], args[1])
				raise "Invalid channel" if channel.nil?
				raise "You can't mirror a channel into itself" if channel.id == ctx[:channel_id]
				Config.mod_s(
					ctx[:guild_id].as(UInt64),
					{f_mirroring: true}
				)
				Config.mod_s(
					ctx[:guild_id].as(UInt64),
					{in_channel: ctx[:channel_id]}
				)
				Config.mod_s(
					ctx[:guild_id].as(UInt64),
					{out_channel: channel.id.to_u64}
				)
				"Mirroring to <##{channel.id}>"
			end
		else
			raise "Unknown subcommand"
		end
	}
end
