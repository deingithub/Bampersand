require "http/client"

Commands.register_command("leo", "Shortens the passed URL using leo.immobilien.", Perms::Level::User) do |args, ctx|
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

Commands.register_command("info", "Displays debug information about you.", Perms::Level::User) do |args, ctx|
  <<-OUT
  Your ID: `#{ctx.issuer.id}`
  Your Permissions: `#{ctx.permissions.value}`
  Your Level: `#{ctx.level}`
  Message Timestamp: `#{ctx.timestamp}`
  OUT
end
