require "../Commands"
require "http/client"

module CommandsUtil
	include Commands
	LEO = ->(args : Array(String), ctx : CommandContext) {
		raise "Invalid arguments" unless args.size == 1
		body = <<-BODY
		{"url": "#{args[0]}"}
		BODY
		response = JSON.parse HTTP::Client.post(
			"https://leo.immobilien/api/create",
			headers: HTTP::Headers{"Content-Type" => "application/json"},
			body: body
		).body
		raise "API Response Negative" unless response["status"] == "success"
		return "https://leo.immobilien/#{response["urlKey"]}"
	}
end
