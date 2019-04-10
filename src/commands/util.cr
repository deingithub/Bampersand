require "../Commands"
require "http/client"
require "../Arguments"

Commands.register_command(
  "leo", "Shorten URLs using leo.immobilien"
) do |args, ctx|
  Arguments.assert_count(args, 1)
  body = <<-BODY
  {"url": "#{args[0]}"}
  BODY
  response = JSON.parse HTTP::Client.post(
    "https://leo.immobilien/api/create",
    headers: HTTP::Headers{"Content-Type" => "application/json"},
    body: body
  ).body
  raise "API Response Negative" unless response["status"] == "success"
  "https://leo.immobilien/#{response["urlKey"]}"
end

TAG_HELP = {
  text: "| tag update <tag-name tag text here>
  | tag delete <tag-name>
  | tag list
  | tag <tag-name>",
  title: "**BAMPERSAND TAGS**"
}

Commands.register_command(
  "tag", "Display and edit custom messages"
) do |args, ctx|
  next TAG_HELP if args.size == 0
  raise "This command can only be used in guilds" if ctx[:guild_id].nil?
  Arguments.assert_count(args, 1)
  guild = ctx[:guild_id].as(UInt64)
  command = args.shift
  case command
  when "update"
    Util.assert_perms(ctx, ManageGuild)
    raise "Missing tag name" unless args.size > 0
    tag_name = args.shift
    raise "Tag name may not contain newlines." if tag_name.includes?("\n")
    raise "Missing tag content" unless args.size > 0
    tag_content = args.join(" ")
    Bampersand::DATABASE.exec "insert into tags (guild_id, name, content) values (?,?,?)",
      guild.to_i64, tag_name, tag_content
    "Updated tag **#{tag_name}**:\n#{tag_content}"
  when "delete"
    Util.assert_perms(ctx, ManageGuild)
    raise "Missing tag name" unless args.size > 0
    tag_name = args.shift
    Bampersand::DATABASE.exec "delete from tags where guild_id == ? and name == ?",
      guild.to_i64, tag_name
    "Deleted tag **#{tag_name}**"
  when "list"
    output = ""
    Bampersand::DATABASE.query "select name from tags where guild_id == ?", guild.to_i64 do |rs|
      rs.each do
        output += " `#{rs.read(String)}`"
      end
    end
    output.size == 0 ? "No tags available" : output
  else
    output = ""
    Bampersand::DATABASE.query "select content from tags where guild_id == ? and name == ?", guild.to_i64, command do |rs|
      rs.each do
        output = rs.read(String)
      end
    end
    raise "Tag not found" if output.size == 0
    {title: "**#{command.upcase}**", text: output}
  end
end
