require "../commands/*"

module Commands
  # This is the module handling command execution
  extend self

  # The data a command is handed apart from the arguments.
  # In contrast to just passing on the message struct, I can add arbitrary
  # fields here.
  record CommandContext,
    issuer : Discord::User,
    channel_id : UInt64,
    guild_id : UInt64?,
    timestamp : Time,
    permissions : Discord::Permissions,
    level : Perms::Level
  record GuildOnlyContext, guild_id : UInt64?

  # Command Metadata
  record CommandInfo, desc : String, level : Perms::Level
  # The type of command executes
  alias CommandType = Proc(Array(String), CommandContext, CommandResult)
  # NT renders to an embed, String to plain text response, bool to ✔ reaction
  alias CommandResult = NamedTuple(title: String, text: String) | String | Bool
  @@command_exec = {} of String => CommandType
  @@command_info = {} of String => CommandInfo

  # This is the function all command definitions use to add their data/exec to
  # the module's registry.
  def register_command(
    name, desc, perms, &execute : Array(String), CommandContext -> CommandResult
  )
    @@command_exec[name] = execute
    @@command_info[name] = CommandInfo.new(desc, perms)
  end

  # Getters
  def command_info
    @@command_info
  end

  def command_execs
    @@command_execs
  end

  # Creates a CommandContext from a message object
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

  # The event handler calls this.
  # On match, execution continues in #run_command.
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

  # Attempts to execute a command. #send_result handles rendering the output.
  def run_command(msg, command, args)
    # Privilege level checking
    unless Perms.check(
             msg.guild_id, msg.author.id, @@command_info[command].level
           )
      fail_str = "Unauthorized. Required: #{@@command_info[command].level}"
      Log.warn(
        "Refused to execute #{command} #{args} for #{msg.author.tag}: #{Perms.get_highest(msg.guild_id, msg.author.id)} < #{@@command_info[command].level}"
      )
      send_result(msg.channel_id, msg.id, command, :error, fail_str)
      return
    end
    begin
      Log.info("#{msg.author.tag} issued #{command} #{args}")
      output = @@command_exec[command].call(
        args, build_context(msg)
      )
      send_result(msg.channel_id, msg.id, command, :success, output)
    rescue e
      send_result(msg.channel_id, msg.id, command, :error, e)
      Log.error "Failed to execute: #{e}"
    end
  end

  # Renders the command output to discord.
  def send_result(channel_id, message_id, command, result, output)
    begin
      if result == :success
        # Strings render to plain-text messages,
        if output.is_a?(String)
          bot!.create_message(channel_id, output)
          # NamedTuples to embeds,
        elsif output.is_a?(NamedTuple(title: String, text: String))
          bot!.create_message(channel_id, "", embed: Discord::Embed.new(
            colour: 0x16161d, description: output[:text], title: output[:title]
          ))
          # And `true` to a ✔ reaction.
        elsif output.is_a?(Bool) && output
          bot!.create_reaction(channel_id, message_id, "✅")
        end
      elsif result == :error
        bot!.create_message(channel_id, "", embed: Discord::Embed.new(
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
