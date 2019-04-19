require "./commands/*"

module Commands
  extend self

  record CommandContext,
    issuer : Discord::User,
    channel_id : UInt64,
    guild_id : UInt64?,
    timestamp : Time,
    permissions : Discord::Permissions,
    level : Perms::Level
  record GuildOnlyContext, guild_id : UInt64?

  alias CommandType = Proc(Array(String), CommandContext, CommandResult)
  alias CommandResult = NamedTuple(title: String, text: String) | String | Bool
  @@COMMANDS = {} of String => CommandType

  def register_command(
    name, &execute : Array(String), CommandContext -> CommandResult
  )
    @@COMMANDS[name] = execute
  end

  def get_commands
    @@COMMANDS
  end

  def build_context(msg : Discord::Message)
    client = Bampersand::CLIENT
    guild = msg.guild_id
    perms = if guild
              member = Bampersand::CACHE.resolve_member(guild, msg.author.id)
              perms_tmp = Discord::Permissions::None
              member.roles.each do |role_id|
                role = Bampersand::CACHE.resolve_role(role_id)
                perms_tmp += role.permissions.value
              end
              perms_tmp
            else
              Discord::Permissions::None
            end
    CommandContext.new(
      issuer: msg.author,
      channel_id: msg.channel_id.to_u64,
      guild_id: guild.try &.to_u64,
      timestamp: msg.timestamp,
      permissions: perms,
      level: Perms.get_highest(guild, msg.author.id)
    )
  end

  def handle_message(msg)
    client = Bampersand::CLIENT
    return unless msg.content.starts_with?(Bampersand::CONFIG["prefix"])
    content = msg.content.lchop(Bampersand::CONFIG["prefix"])
    arguments = content.split(" ")
    command = arguments.shift
    return unless @@COMMANDS[command]?
    output = ""
    begin
      Log.info "#{msg.author.username}##{msg.author.discriminator} issued #{command} #{arguments}"
      output = @@COMMANDS[command].call(
        arguments, build_context(msg)
      )
      send_result(client, msg.channel_id, msg.id, command, :success, output)
    rescue e
      send_result(client, msg.channel_id, msg.id, command, :error, e)
      Log.error "Failed to execute: #{e}"
    end
  end

  def send_result(client, channel_id, message_id, command, result, output)
    ctx = GuildOnlyContext.new(
      guild_id: Util.guild(client, channel_id).try &.to_u64,
    )
    begin
      if result == :success
        if output.is_a?(String)
          client.create_message(channel_id, output)
        elsif output.is_a?(NamedTuple(title: String, text: String))
          client.create_message(channel_id, "", embed: Discord::Embed.new(
            colour: 0x16161d, description: output[:text], title: output[:title]
          ))
        elsif output.is_a?(Bool) && output
          client.create_reaction(channel_id, message_id, "✅")
        end
      elsif result == :error
        client.create_message(channel_id, "", embed: Discord::Embed.new(
          title: L10N.do("command_failed", command).upcase,
          colour: 0xdd2e44,
          description: "`#{output.to_s}`"
        ))
      end
    rescue e
      Log.error "Failed to deliver #{result} message to #{channel_id}: #{e}"
    end
  end

  Log.info(
    "Loaded #{Commands.get_commands.size} commands: #{Commands.get_commands.keys}"
  )
end
