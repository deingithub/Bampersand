Commands.register_command("ping") do |args, ctx|
  ping = Time.utc_now - ctx.timestamp
  ":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample + " | `#{ping.total_milliseconds.to_i}ms`"
end

Commands.register_command("help") do |args, ctx|
  output = ""
  Commands.get_commands.keys.each do |name|
    output += "`#{Bampersand::CONFIG["prefix"]}#{name}` | "
  end
  output = output.rchop("| ")
  output += "\n\n"
  output += "See `#{Bampersand::CONFIG["prefix"]}about` for more info."
  {title: "**BAMPERSAND COMMANDS**", text: output}
end

Commands.register_command("about") do |args, ctx|
  uptime = Time.monotonic - Bampersand::STARTUP
  {
    title: "**BAMPERSAND VERSION #{Bampersand::VERSION}**",
    text:  "This is a simple utility bot for Discord powered by [Crystal](https://crystal-lang.org).\nYou can take a peek <:blobpeek:559732380697362482> at the [documentation](https://git.15318.de/Dingens/Bampersand/wiki/Home) and the [source code](https://git.15318.de/Dingens/Bampersand)!\nCurrently running on #{Bampersand::CACHE.guilds.size} guilds, serving #{Bampersand::CACHE.users.size} users.\nUptime is #{uptime.days}d #{uptime.hours}h #{uptime.minutes}m #{uptime.seconds}s. Bot operator is <@#{Bampersand::CONFIG["admin"]}>.",
  }
end

Commands.register_command("ops") do |args, ctx|
  Perms.assert_level(Operator)
  Arguments.assert_count(args, 1)
  command = args.shift.downcase
  case command
  when "restart"
    system("sudo systemctl restart bampersand")
    raise "You should not be able to see this."
  when "rebuild"
    raise "Pull failed" unless system("git pull origin master")
    raise "Build failed" unless system("shards build --release")
    "Successfully rebuilt in #{Time.utc_now - ctx.timestamp}."
  else
    raise "Unknown subcommand"
  end
end
