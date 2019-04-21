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
