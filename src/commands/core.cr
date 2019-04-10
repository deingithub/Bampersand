require "../Commands"
require "../L10N"

Commands.register_command(
  "ping", "Check if the bot's still alive"
) do |args, ctx|
  ":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample
end

Commands.register_command("help", "This command.") do |args, ctx|
  output = ""
  Commands.get_commands.each do |(name, data)|
    output += "| #{name} — #{data[:desc]}\n"
  end
  output += L10N.do("help_info_line", Bampersand::CONFIG["prefix"])
  {title: L10N.do("help_title"), text: output}
end

Commands.register_command("about", "About Bampersand") do |args, ctx|
  uptime = Time.monotonic - Bampersand::STARTUP
  {
    title: L10N.do("about_title", Bampersand::VERSION),
    text:  L10N.do(
      "about_text", ctx[:client].cache.as(Discord::Cache).guilds.size,
      ctx[:client].cache.as(Discord::Cache).users.size, uptime.days,
      uptime.hours, uptime.minutes, uptime.seconds, Bampersand::CONFIG["admin"]
    ),
  }
end
