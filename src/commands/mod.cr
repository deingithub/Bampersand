require "../Commands"
require "../Util"
require "../Arguments"
require "../L10N"
require "../ModTools"
require "../Perms"

Commands.register_command("ban") do |args, ctx|
  Perms.assert_perms(ctx, Moderator)
  Arguments.assert_count(args, 1)
  output = L10N.do("ban_title", args.size, ctx.issuer.id)
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      Bampersand::CLIENT.create_guild_ban(
        guild_id, user.id, nil,
        "Banned by Bampersand on behalf of #{ctx.issuer.username}##{ctx.issuer.discriminator} (#{ctx.issuer.id}) at #{Time.utc_now}."
      )
      output += L10N.do("ban_successful", argument) + "\n"
    rescue
      output += L10N.do("ban_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("kick") do |args, ctx|
  Perms.assert_perms(ctx, Moderator)
  Arguments.assert_count(args, 1)
  output = L10N.do("kick_title", args.size, ctx.issuer.id)
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      Bampersand::CLIENT.remove_guild_member(guild_id, user.id)
      output += L10N.do("kick_successful", argument) + "\n"
    rescue
      output += L10N.do("kick_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("unban") do |args, ctx|
  Perms.assert_perms(ctx, Moderator)
  Arguments.assert_count(args, 1)
  output = L10N.do("unban_title", args.size, ctx.issuer.id)
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      Bampersand::CLIENT.remove_guild_ban(guild_id, user.id)
      output += L10N.do("unban_successful", argument) + "\n"
    rescue
      output += L10N.do("unban_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("mute") do |args, ctx|
  Perms.assert_perms(ctx, Moderator)
  Arguments.assert_count(args, 1)
  mute_role = ModTools.mute_role?(ctx.guild_id.not_nil!)
  mute_role = ModTools.create_mute_role(ctx.guild_id.not_nil!) if mute_role.nil?
  output = L10N.do("mute_title", args.size, ctx.issuer.id)
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      Bampersand::CLIENT.add_guild_member_role(guild_id, user.id.to_u64, mute_role.id.to_u64)
      output += L10N.do("mute_successful", argument) + "\n"
    rescue
      output += L10N.do("mute_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("unmute") do |args, ctx|
  Perms.assert_perms(ctx, Moderator)
  Arguments.assert_count(args, 1)
  mute_role = ModTools.mute_role?(ctx.guild_id.not_nil!)
  raise L10N.do("unmute_no_role") if mute_role.nil?
  output = L10N.do("unmute_title", args.size, ctx.issuer.id)
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      Bampersand::CLIENT.remove_guild_member_role(guild_id, user.id.to_u64, mute_role.id.to_u64)
      output += L10N.do("unmute_successful", argument) + "\n"
    rescue
      output += L10N.do("unmute_failed", argument) + "\n"
    end
  end
  {title: "", text: output}
end

WARN_HELP = {
  text: "| warn add <@user> <optional reason>
  | warn list <@user>
  | warn remove <@user>
  | warn expunge <@user>",
  title: "**BAMPERSAND WARNINGS**",
}

Commands.register_command("warn") do |args, ctx|
  Perms.assert_perms(ctx, Moderator)
  if args.size == 0
    next WARN_HELP
  end
  Arguments.assert_count(args, 2)
  command = args.shift.downcase
  target_user = Arguments.to_user(args.shift)
  case command
  when "add"
    reason = args.size > 0 ? args.join(" ") : ""
    Bampersand::DATABASE.exec "insert into warnings (guild_id, user_id, mod_id, text) values (?,?,?,?)", ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64, ctx.issuer.id.to_u64.to_i64, reason
    {
      title: "Warning added for #{target_user.username}##{target_user.discriminator}",
      text:  "Responsible Moderator: <@#{ctx.issuer.id}>\n#{reason}",
    }
  when "list"
    output = ""
    count = 0
    Bampersand::DATABASE.query "select mod_id, text, timestamp from warnings where guild_id == ? and user_id == ?", ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64 do |rs|
      rs.each do
        mod_id = rs.read(Int64)
        text = rs.read(String)
        timestamp = rs.read(String)
        output += "**##{count + 1}** #{timestamp} UTC (<@#{mod_id}>)\n#{text}\n"
        count += 1
      end
    end
    {title: "**#{target_user.username}##{target_user.discriminator}: #{count} warning/s**".upcase, text: output}
  when "remove"
    Bampersand::DATABASE.exec "delete from warnings where guild_id == ? and user_id == ? limit 1", ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64
    true
  when "expunge"
    Perms.assert_perms(ctx, Admin)
    Bampersand::DATABASE.exec "delete from warnings where guild_id == ? and user_id == ?", ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64
    true
  else
    raise "Unknown subcommand"
  end
end
