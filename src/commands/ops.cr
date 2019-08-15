require "../modules/Commands"

Commands.register_command("ops restart", "Restarts Bampersand.", Perms::Level::Operator) do
  system("sudo systemctl restart bampersand")
  raise "You should not be able to see this."
end
Commands.register_command("ops rebuild", "Rebuilds Bampersand from the latest source.", Perms::Level::Operator) do |_args, ctx|
  raise "Pull failed" unless system("git pull origin master")
  raise "Build failed" unless system("shards build --release")
  "Successfully rebuilt in #{Time.utc_now - ctx.message.timestamp}."
end
Commands.register_command("ops blacklist", "Adds a guild to the killfile and leaves it.", Perms::Level::Operator) do |args|
  Arguments.assert_count(args, 1)
  Killfile.add_to_killfile(args[0].to_u64)
  true
end
