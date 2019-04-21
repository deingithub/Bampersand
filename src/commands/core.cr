Commands.register_command("ping", "Pongs you.", Perms::Level::User) do |args, ctx|
  ping = Time.utc_now - ctx.timestamp
  ":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample + " | `#{ping.total_milliseconds.to_i}ms`"
end

Commands.register_command("help", "Lists commands. Pass a single argument to search command descriptions.", Perms::Level::User) do |args, ctx|
  output = if args.size != 1
             Commands.command_info.keys.select { |e| !e.includes?(" ") }.reduce(" ") { |memo, e| memo + "*`#{e}`*, " }.rchop(", ")
           else
             Commands.command_info.keys.select { |e| e.includes?(args[0]) }.sort!.reduce(" ") { |memo, e| memo + "*`#{e}`* #{Commands.command_info[e].desc}\n" }
           end
  {text: output.lstrip.size > 0 ? output : "No results found.", title: "Commands"}
end

Commands.register_command("about",
  "Displays stats about Bampersand and links to further resources.",
  Perms::Level::User) do |args, ctx|
  uptime = Time.monotonic - Bampersand::STARTUP
  {
    title: "**BAMPERSAND VERSION #{Bampersand::VERSION}**",
    text:  "This is a simple utility bot for Discord powered by [Crystal](https://crystal-lang.org).\nYou can take a peek <:blobpeek:559732380697362482> at the [documentation](https://git.15318.de/Dingens/Bampersand/wiki/Home) and the [source code](https://git.15318.de/Dingens/Bampersand)!\nCurrently running on #{cache!.guilds.size} guilds, serving #{cache!.users.size} users.\nUptime is #{uptime.days}d #{uptime.hours}h #{uptime.minutes}m #{uptime.seconds}s. Bot operator is <@#{ENV["admin"]}>.",
  }
end

Commands.register_command("ops restart",
  "Restarts Bampersand.",
  Perms::Level::Operator) do |args, ctx|
  system("sudo systemctl restart bampersand")
  raise "You should not be able to see this."
end
Commands.register_command("ops rebuild",
  "Rebuilds Bampersand from the latest source.",
  Perms::Level::Operator) do |args, ctx|
  raise "Pull failed" unless system("git pull origin master")
  raise "Build failed" unless system("shards build --release")
  "Successfully rebuilt in #{Time.utc_now - ctx.timestamp}."
end
