require "../Commands"
require "../Util"
require "../Arguments"
require "../L10N"
require "../ModTools"

Commands.register_command("ban") do |args, ctx|
  Util.assert_guild(ctx)
  Util.assert_perms(ctx, BanMembers)
  Arguments.assert_count(args, 1)
  output = L10N.do("ban_title", args.size, ctx[:issuer].id)
  guild_id = ctx[:guild_id].as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      ctx[:client].create_guild_ban(
        guild_id, user.id, nil,
        "Banned by Bampersand on behalf of #{ctx[:issuer].username}##{ctx[:issuer].discriminator} (#{ctx[:issuer].id}) at #{Time.utc_now}."
      )
      output += L10N.do("ban_successful", argument) + "\n"
    rescue
      output += L10N.do("ban_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("kick") do |args, ctx|
  Util.assert_guild(ctx)
  Util.assert_perms(ctx, KickMembers)
  Arguments.assert_count(args, 1)
  output = L10N.do("kick_title", args.size, ctx[:issuer].id)
  guild_id = ctx[:guild_id].as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      ctx[:client].remove_guild_member(guild_id, user.id)
      output += L10N.do("kick_successful", argument) + "\n"
    rescue
      output += L10N.do("kick_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("unban") do |args, ctx|
  Util.assert_guild(ctx)
  Util.assert_perms(ctx, BanMembers)
  Arguments.assert_count(args, 1)
  output = L10N.do("unban_title", args.size, ctx[:issuer].id)
  guild_id = ctx[:guild_id].as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      ctx[:client].remove_guild_ban(guild_id, user.id)
      output += L10N.do("unban_successful", argument) + "\n"
    rescue
      output += L10N.do("unban_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("mute") do |args, ctx|
  Util.assert_guild(ctx)
  Util.assert_perms(ctx, ManageMessages)
  Arguments.assert_count(args, 1)
  mute_role = ModTools.mute_role?(ctx[:guild_id].not_nil!)
  mute_role = ModTools.create_mute_role(ctx[:guild_id].not_nil!) if mute_role.nil?
  output = L10N.do("mute_title", args.size, ctx[:issuer].id)
  guild_id = ctx[:guild_id].as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      ctx[:client].add_guild_member_role(guild_id, user.id.to_u64, mute_role.id.to_u64)
      output += L10N.do("mute_successful", argument) + "\n"
    rescue
      output += L10N.do("mute_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("unmute") do |args, ctx|
  Util.assert_guild(ctx)
  Util.assert_perms(ctx, ManageMessages)
  Arguments.assert_count(args, 1)
  mute_role = ModTools.mute_role?(ctx[:guild_id].not_nil!)
  raise L10N.do("unmute_no_role") if mute_role.nil?
  output = L10N.do("unmute_title", args.size, ctx[:issuer].id)
  guild_id = ctx[:guild_id].as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      ctx[:client].remove_guild_member_role(guild_id, user.id.to_u64, mute_role.id.to_u64)
      output += L10N.do("unmute_successful", argument) + "\n"
    rescue
      output += L10N.do("unmute_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end
