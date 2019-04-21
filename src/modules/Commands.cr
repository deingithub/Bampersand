require "../commands/*"

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
  record CommandInfo, desc : String, level : Perms::Level

  alias CommandType = Proc(Array(String), CommandContext, CommandResult)
  alias CommandResult = NamedTuple(title: String, text: String) | String | Bool
  @@command_exec = {} of String => CommandType
  @@command_info = {} of String => CommandInfo

  def register_command(
    name, desc, perms, &execute : Array(String), CommandContext -> CommandResult
  )
    @@command_exec[name] = execute
    @@command_info[name] = CommandInfo.new(desc, perms)
  end

  def command_info
    @@command_info
  end
  def command_execs
    @@command_execs
  end

  def build_context(msg : Discord::Message)
    client = bot!
    guild = msg.guild_id
    perms = if guild
              member = cache!.resolve_member(guild, msg.author.id)
              perms_tmp = Discord::Permissions::None
              member.roles.each do |role_id|
                role = cache!.resolve_role(role_id)
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
    return unless msg.content.starts_with?(ENV["prefix"])
    content = msg.content.lchop(ENV["prefix"])
    @@command_exec.keys.each do |key|
      next unless content.starts_with? key
      arguments = content.lchop(key).split(" ")
      arguments.delete("")
      output = ""
      run_command(msg, key, arguments)
      break
    end
  end

  def run_command(msg, command, args)
    unless Perms.check(msg.guild_id, msg.author.id, @@command_info[command].level)
      fail_str = "Unauthorized. Required: #{@@command_info[command].level}"
      Log.warn "Refused to execute #{command} #{args} for #{msg.author.username}##{msg.author.discriminator}: Level Mismatch #{Perms.get_highest(msg.guild_id, msg.author.id)} < #{@@command_info[command].level}"
      send_result(bot!, msg.channel_id, msg.id, command, :error, fail_str)
      return
    end
    begin
      Log.info "#{msg.author.username}##{msg.author.discriminator} issued #{command} #{args}"
      output = @@command_exec[command].call(
        args, build_context(msg)
      )
      send_result(bot!, msg.channel_id, msg.id, command, :success, output)
    rescue e
      send_result(bot!, msg.channel_id, msg.id, command, :error, e)
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
          title: "**failed to execute: #{command}**".upcase,
          colour: 0xdd2e44,
          description: "`#{output.to_s}`"
        ))
      end
    rescue e
      Log.error "Failed to deliver #{result} message to #{channel_id}: #{e}"
    end
  end

  Log.info(
    "Loaded #{Commands.command_info.size} commands: #{Commands.command_info.keys}"
  )
end
