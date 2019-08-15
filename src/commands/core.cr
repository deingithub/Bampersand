require "../modules/Commands"

PINGS = ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."]
Commands.register_command("ping", "Pongs you.", Perms::Level::User) do |_args, ctx|
  ping = Time.utc_now - ctx.message.timestamp
  ":ping_pong: " + PINGS.sample + " | `#{ping.total_milliseconds.to_i}ms`"
end

Commands.register_command("help", "Lists commands. Pass a single argument to search for commands.", Perms::Level::User) do |args|
  output = ""
  if args.empty?
    output = Commands.registry.keys.reject(&.includes?(" ")).reduce(" ") do |memo, e|
      memo + "*`#{e}`*, "
    end.rchop(", ")
  else
    output = Commands.registry.keys.select(&.includes?(args[0])).sort!.reduce(" ") do |memo, e|
      memo + "*`#{e}`* #{Commands.registry[e].description}\n"
    end
  end
  {
    text:  output.lstrip.size > 0 ? output : "No results found.",
    title: "Commands",
  }
end

Commands.register_command("about", "Displays stats about Bampersand and links to further resources.", Perms::Level::User) do
  uptime = Time.monotonic - STARTUP
  {
    title: "**BAMPERSAND VERSION #{VERSION}**",
    text:  "This is a simple utility bot for Discord powered by [Crystal](https://crystal-lang.org).\nYou can take a peek <:blobpeek:559732380697362482> at the [documentation](https://git.15318.de/Dingens/Bampersand/wiki/Home) and the [source code](https://git.15318.de/Dingens/Bampersand)!\nCurrently running on #{CACHE.guilds.size} guilds, serving #{CACHE.users.size} users.\nUptime is #{uptime.days}d #{uptime.hours}h #{uptime.minutes}m #{uptime.seconds}s. Bot operator is <@#{ENV["admin"]}>.",
  }
end
