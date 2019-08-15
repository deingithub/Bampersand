require "../modules/Commands"

Commands.register_command("tag update", "Updates/creates the tag with the passed name to the passed content.", Perms::Level::Moderator) do |args, ctx|
  guild_id = Util.assert_guild(ctx)
  Arguments.assert_count(args, 2)
  tag_name = args.shift
  raise "Tag name may not contain newlines." if tag_name.includes?("\n")
  tag_content = args.join(" ")
  DATABASE.exec(
    "insert into tags (guild_id, name, content) values (?,?,?)",
    guild_id.to_i64, tag_name, tag_content
  )
  true
end
Commands.register_command("tag delete", "Deletes the tag with the passed name.", Perms::Level::Moderator) do |args, ctx|
  guild_id = Util.assert_guild(ctx)
  Arguments.assert_count(args, 1)
  tag_name = args.shift
  DATABASE.exec(
    "delete from tags where guild_id == ? and name == ?",
    guild_id.to_i64, tag_name
  )
  true
end
Commands.register_command("tag list", "Lists all defined tags.", Perms::Level::User) do |_args, ctx|
  guild_id = Util.assert_guild(ctx)
  output = ""
  DATABASE.query(
    "select name from tags where guild_id == ?", guild_id.to_i64
  ) do |rs|
    rs.each do
      output += " `#{rs.read(String)}`"
    end
  end
  output.size == 0 ? "No tags available" : output
end

TAG_HELP = {
  text: "| tag update <tag-name tag text here>
  | tag delete <tag-name>
  | tag list
  | tag <tag-name>",
  title: "**BAMPERSAND TAGS**",
}
Commands.register_command("tag", "[Edit and display custom messages]", Perms::Level::User) do |args, ctx|
  next TAG_HELP if args.size == 0
  guild_id = Util.assert_guild(ctx)
  tag_name = args.shift
  output = ""
  DATABASE.query(
    "select content from tags where guild_id == ? and name == ?",
    guild_id.to_i64, tag_name
  ) do |rs|
    rs.each do
      output = rs.read(String)
    end
  end
  raise "No such tag" if output.size == 0
  {title: "**#{tag_name.upcase}**", text: output}
end
