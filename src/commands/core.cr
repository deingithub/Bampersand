require "../Commands"
require "../Arguments"
require "../L10N"
require "../Perms"

Commands.register_command("ping") do |args, ctx|
  ping = Time.utc_now - ctx.timestamp
  {
    title: "#{ping.total_milliseconds}ms",
    text:  ":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample,
  }
end

Commands.register_command("help") do |args, ctx|
  output = ""
  Commands.get_commands.keys.each do |name|
    output += "`#{Bampersand::CONFIG["prefix"]}#{name}` | "
  end
  output = output.rchop("| ")
  output += "\n\n"
  output += L10N.do("help_info_line", Bampersand::CONFIG["prefix"])
  {title: L10N.do("help_title"), text: output}
end

Commands.register_command("about") do |args, ctx|
  uptime = Time.monotonic - Bampersand::STARTUP
  {
    title: L10N.do("about_title", Bampersand::VERSION),
    text:  L10N.do(
      "about_text", Bampersand::CACHE.guilds.size,
      Bampersand::CACHE.users.size, uptime.days,
      uptime.hours, uptime.minutes, uptime.seconds, Bampersand::CONFIG["admin"]
    ),
  }
end

Commands.register_command("ops") do |args, ctx|
  Perms.assert_level(Operator)
  Arguments.assert_count(args, 1)
  command = args.shift.downcase
  case command
  when "restart"
    system("sudo systemctl restart bampersand")
    raise "Don't panic"
  when "rebuild"
    raise "Pull failed" unless system("git pull origin master")
    raise "Build failed" unless system("shards build --release")
    "Successfully rebuilt in #{Time.utc_now - ctx.timestamp}."
  else
    raise "Unknown subcommand"
  end
end
