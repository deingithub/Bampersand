# This file contains additions to discordcr that haven't been merged yet

module Discord
  struct User
    def tag
      "#{self.username}##{self.discriminator}"
    end
  end

  struct Snowflake
    def to_i64
      self.to_u64.to_i64
    end
  end
end
