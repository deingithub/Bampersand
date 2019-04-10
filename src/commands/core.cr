require "../Commands"

Commands.register_command(
  "ping", "Check if the bot's still alive"
) do |args, ctx|
  ":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample
end

Commands.register_command("help", "This command.") do |args, ctx|
  acc = ""
  Commands.get_commands.each do |(name, data)|
    acc += "| #{name} — #{data[:desc]}\n"
  end
  acc += "Prefix is `#{Bampersand::CONFIG["prefix"]}`. See `about` for more information."
  {title: "**BAMPERSAND COMMANDS**", text: acc}
end

Commands.register_command("about", "About Bampersand") do |args, ctx|
  uptime = Time.monotonic - Bampersand::STARTUP
  text = <<-STR
  This is a simple utility bot for Discord powered by [Crystal](https://crystal-lang.org).
  You can take a peek <:blobpeek:559732380697362482> at the [documentation](https://15318.de/bampersand) and the [source code](https://gitlab.com/deing/bampersand).
  Currently running on #{ctx[:client].cache.as(Discord::Cache).guilds.size} guilds, serving #{ctx[:client].cache.as(Discord::Cache).users.size} users.
  Uptime is #{uptime.days}d #{uptime.hours}h #{uptime.minutes}m #{uptime.seconds}s. Bot operator is <@#{Bampersand::CONFIG["admin"]}>.
  STR
  {title: "**BAMPERSAND VERSION #{Bampersand::VERSION}**", text: text}
end
