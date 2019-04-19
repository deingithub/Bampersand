require "../Commands"
require "http/client"
require "../Arguments"
require "../L10N"
require "../Perms"

Commands.register_command("leo") do |args, ctx|
  Arguments.assert_count(args, 1)
  body = <<-BODY
  {"url": "#{args[0]}"}
  BODY
  response = JSON.parse HTTP::Client.post(
    "https://leo.immobilien/api/create",
    headers: HTTP::Headers{"Content-Type" => "application/json"},
    body: body
  ).body
  raise L10N.do("leo_bad_api") unless response["status"] == "success"
  "https://leo.immobilien/#{response["urlKey"]}"
end

TAG_HELP = {
  text: "| tag update <tag-name tag text here>
  | tag delete <tag-name>
  | tag list
  | tag <tag-name>",
  title: "**BAMPERSAND TAGS**",
}

Commands.register_command("tag") do |args, ctx|
  next TAG_HELP if args.size == 0
  Util.assert_guild(ctx)
  Arguments.assert_count(args, 1)
  guild = ctx.guild_id.as(UInt64)
  command = args.shift
  case command
  when "update"
    Perms.assert_level(Moderator)
    Arguments.assert_count(args, 2)
    tag_name = args.shift
    raise L10N.do("tag_no_newlines") if tag_name.includes?("\n")
    tag_content = args.join(" ")
    Bampersand::DATABASE.exec "insert into tags (guild_id, name, content) values (?,?,?)",
      guild.to_i64, tag_name, tag_content
    true
  when "delete"
    Perms.assert_level(Moderator)
    Arguments.assert_count(args, 1)
    tag_name = args.shift
    Bampersand::DATABASE.exec "delete from tags where guild_id == ? and name == ?",
      guild.to_i64, tag_name
    true
  when "list"
    output = ""
    Bampersand::DATABASE.query "select name from tags where guild_id == ?", guild.to_i64 do |rs|
      rs.each do
        output += " `#{rs.read(String)}`"
      end
    end
    output.size == 0 ? L10N.do("tag_no_tags") : output
  else
    output = ""
    Bampersand::DATABASE.query "select content from tags where guild_id == ? and name == ?", guild.to_i64, command do |rs|
      rs.each do
        output = rs.read(String)
      end
    end
    raise L10N.do("tag_not_found") if output.size == 0
    {title: "**#{command.upcase}**", text: output}
  end
end

Commands.register_command("info") do |args, ctx|
  <<-OUT
  Your ID: `#{ctx.issuer.id}`
  Your Permissions: `#{ctx.permissions.value}`
  Your Level: `#{ctx.level}`
  Message Timestamp: `#{ctx.timestamp}`
  OUT
end
