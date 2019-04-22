# This file contains additions to discordcr that haven't been merged yet

module Discord::REST
  # Changes the position of roles. Requires the "Manage Roles" permission
  # and you cannot raise roles above the bot's highest role.
  #
  # [API docs for this method](https://discordapp.com/developers/docs/resources/guild#modify-guild-role-positions)
  def modify_guild_role_positions(guild_id : UInt64 | Snowflake,
                                  positions : Array(ModifyRolePositionPayload))
    response = request(
      :guilds_gid_roles,
      guild_id,
      "PATCH",
      "/guilds/#{guild_id}/roles",
      HTTP::Headers{"Content-Type" => "application/json"},
      positions.to_json
    )

    Array(Role).from_json(response.body)
  end

  struct ModifyRolePositionPayload
    JSON.mapping(
      id: Snowflake,
      position: Int32
    )

    def initialize(id : UInt64 | Snowflake, @position : Int32)
      id = Snowflake.new(id) unless id.is_a?(Snowflake)
      @id = id
    end
  end
end

module Discord
  struct User
    def tag
      "#{self.username}##{self.discriminator}"
    end
  end
end
