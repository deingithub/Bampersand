require "./spec_helper"

context Commands do
	it "loaded commands" do
		Commands.command_info.size > 0
	end
end
