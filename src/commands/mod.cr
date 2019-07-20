Commands.register_command("ban", "Attempts to ban all mentioned users.", Perms::Level::Admin) do |args, ctx|
  Arguments.assert_count(args, 1)
  output = "Attempting to ban #{args.size} members…\nResponsible Moderator: <@#{ctx.issuer.id}>\n"
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      bot!.create_guild_ban(
        guild_id, user.id, nil,
        "Banned by Bampersand on behalf of #{ctx.issuer.tag} (#{ctx.issuer.id}) at #{Time.utc_now}."
      )
      output += ":heavy_check_mark: Banned <@#{user.id}>" + "\n"
    rescue
      output += ":x: Failed to ban #{argument}\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("kick", "Attempts to kick all mentioned users.", Perms::Level::Moderator) do |args, ctx|
  Arguments.assert_count(args, 1)
  output = "Attempting to kick #{args.size} members…\nResponsible Moderator: <@#{ctx.issuer.id}>\n"
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      bot!.remove_guild_member(guild_id, user.id)
      output += ":heavy_check_mark: Kicked <@#{user.id}>" + "\n"
    rescue
      output += ":x: Failed to kick #{argument}\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("unban", "Attempts to unban all mentioned users.", Perms::Level::Admin) do |args, ctx|
  Arguments.assert_count(args, 1)
  output = "Attempting to unban #{args.size} members…\nResponsible Moderator: <@#{ctx.issuer.id}>\n"
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      bot!.remove_guild_ban(guild_id, user.id)
      output += ":heavy_check_mark: Pardoned <@#{user.id}>" + "\n"
    rescue
      output += ":x: Failed to unban #{argument}\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("mute", "Attempts to mute all mentioned users.", Perms::Level::Moderator) do |args, ctx|
  Arguments.assert_count(args, 1)
  mute_role = ModTools.mute_role?(ctx.guild_id.not_nil!)
  mute_role = ModTools.create_mute_role(ctx.guild_id.not_nil!) if mute_role.nil?
  output = "Attempting to mute #{args.size} members…\nResponsible Moderator: <@#{ctx.issuer.id}>\n"
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      bot!.add_guild_member_role(guild_id, user.id.to_u64, mute_role.id.to_u64)
      output += ":heavy_check_mark: Muted <@#{user.id}>" + "\n"
    rescue
      output += ":x: Failed to mute #{argument}\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("unmute", "Attempts to unmute all mentioned users.", Perms::Level::Moderator) do |args, ctx|
  Arguments.assert_count(args, 1)
  mute_role = ModTools.mute_role?(ctx.guild_id.not_nil!)
  raise "Mute role not found." if mute_role.nil?
  output = "Attempting to unmute #{args.size} members…\nResponsible Moderator: <@#{ctx.issuer.id}>\n"
  guild_id = ctx.guild_id.as(UInt64)
  args.each do |argument|
    begin
      user = Arguments.to_user(argument)
      bot!.remove_guild_member_role(
        guild_id, user.id.to_u64, mute_role.id.to_u64
      )
      output += ":heavy_check_mark: Unmuted <@#{user.id}>" + "\n"
    rescue
      output += ":x: Failed to unmute #{argument}\n"
    end
  end
  {title: "", text: output}
end

Commands.register_command("warn add", "Adds a warning for the mentioned user, reason optional.", Perms::Level::Moderator) do |args, ctx|
  target_user = Arguments.at_position(args, 0, :user).as(Discord::User)
  reason = args.size > 0 ? args[1..].join(" ") : ""
  Bampersand::DATABASE.exec(
    "insert into warnings (guild_id, user_id, mod_id, text) values (?,?,?,?)",
    ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64,
    ctx.issuer.id.to_u64.to_i64, reason)
  {
    title: "Warning added for #{target_user.tag}",
    text:  "Responsible Moderator<@#{ctx.issuer.id}>\n#{reason}",
  }
end
Commands.register_command("warn list", "Lists all warnings for the mentioned user.", Perms::Level::Moderator) do |args, ctx|
  target_user = Arguments.at_position(args, 0, :user).as(Discord::User)
  output = ""
  count = 0
  Bampersand::DATABASE.query(
    "select mod_id, text, timestamp from warnings where guild_id == ? and user_id == ?",
    ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64
  ) do |rs|
    rs.each do
      mod_id = rs.read(Int64)
      text = rs.read(String)
      timestamp = rs.read(String)
      output += "**##{count + 1}** #{timestamp} UTC (<@#{mod_id}>)\n#{text}\n"
      count += 1
    end
  end
  {title: "**#{target_user.tag}: #{count} warning/s**".upcase, text: output}
end
Commands.register_command("warn remove", "Removes the oldest warning for the mentioned user.", Perms::Level::Moderator) do |args, ctx|
  target_user = Arguments.at_position(args, 0, :user).as(Discord::User)
  Bampersand::DATABASE.exec(
    "delete from warnings where guild_id == ? and user_id == ? limit 1",
    ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64
  )
  true
end
Commands.register_command("warn expunge", "Removes all warnings for the mentioned user.", Perms::Level::Admin) do |args, ctx|
  target_user = Arguments.at_position(args, 0, :user).as(Discord::User)
  Bampersand::DATABASE.exec(
    "delete from warnings where guild_id == ? and user_id == ?",
    ctx.guild_id.not_nil!.to_i64, target_user.id.to_u64.to_i64
  )
  true
end

Commands.register_command("warn", "[Store warnings about users]", Perms::Level::Moderator) do
  {
    text: "| warn add <@user> <optional reason>
    | warn list <@user>
    | warn remove <@user>
    | warn expunge <@user>",
    title: "**BAMPERSAND WARNINGS**",
  }
end
