# This file contains additions to discordcr that haven't been merged yet

module Discord
  struct User
    def tag
      "#{self.username}##{self.discriminator}"
    end
  end
end
