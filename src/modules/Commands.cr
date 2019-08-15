require "../Perms"

require "../commands/*"

module Commands
  # This is the module handling command execution
  extend self

  # The data a command is handed apart from the arguments.
  # In contrast to just passing on the message struct, I can add arbitrary
  # fields here.
  record CommandContext,
    message : Discord::Message,
    issuer : Discord::User,
    permissions : Discord::Permissions,
    level : Perms::Level
  record GuildOnlyContext, guild_id : UInt64?

  # Command Metadata
  record Command, description : String, level : Perms::Level, exec : CommandExecType
  # The type of command executes
  alias CommandExecType = Proc(Array(String), CommandContext, CommandResult)
  # NT renders to an embed, String to plain text response, bool to ✔ reaction
  alias CommandResult = NamedTuple(title: String, text: String) | String | Bool
  @@registry = {} of String => Command

  # This is the function all command definitions use to add their data/exec to
  # the module's registry.
  def register_command(
    name, desc, perms, &execute : Array(String), CommandContext -> CommandResult
  )
    @@registry[name] = Command.new(desc, perms, execute)
  end

  def registry
    @@registry
  end

  def handle_message(msg)
    return unless msg.content.starts_with?(ENV["prefix"])
    content = msg.content.lchop(ENV["prefix"])
    @@registry.keys.each do |key|
      next unless content.starts_with? key
      arguments = content.lchop(key).split(" ")
      arguments.delete("")
      run_command(msg, key, arguments)
      break
    end
  end

  # Attempts to execute a command. #send_result handles rendering the output.
  def run_command(msg, command, args)
    # Privilege level checking
    unless Perms.check(msg.guild_id, msg.author.id, @@registry[command].level)
      LOG.warn(
        "Refused to execute #{command} #{args} for #{msg.author.tag}: #{Perms.get_highest(msg.guild_id, msg.author.id)} < #{@@registry[command].level}"
      )
      send_result(msg.channel_id, msg.id, command, :error, "Unauthorized. Required: #{@@registry[command].level}")
      return
    end
    begin
      LOG.info("#{msg.author.tag} issued #{command} #{args}")
      output = @@registry[command].exec.call(args, build_context(msg))
      send_result(msg.channel_id, msg.id, command, :success, output)
    rescue e
      send_result(msg.channel_id, msg.id, command, :error, e)
      LOG.error "Failed to execute: #{e}"
    end
  end

  # Creates a CommandContext from a message object
  def build_context(msg : Discord::Message)
    guild = msg.guild_id
    perms = Discord::Permissions::None
    if guild
      member = CACHE.resolve_member(guild, msg.author.id)
      perms_tmp = Discord::Permissions::None
      member.roles.each do |role_id|
        role = CACHE.resolve_role(role_id)
        perms_tmp += role.permissions.value
      end
      perms = perms_tmp
    end
    CommandContext.new(
      message: msg,
      issuer: msg.author,
      permissions: perms,
      level: Perms.get_highest(guild, msg.author.id)
    )
  end

  # Renders the command output to discord.
  def send_result(channel_id, message_id, command, result, output)
    if result == :success
      # Strings render to plain-text messages,
      if output.is_a?(String)
        BOT.create_message(channel_id, output)
        # NamedTuples to embeds,
      elsif output.is_a?(NamedTuple(title: String, text: String))
        BOT.create_message(channel_id, "", embed: Discord::Embed.new(
          colour: 0x16161d, description: output[:text], title: output[:title]
        ))
        # And `true` to a ✔ reaction.
      elsif output.is_a?(Bool) && output
        BOT.create_reaction(channel_id, message_id, "✅")
      end
    elsif result == :error
      BOT.create_message(channel_id, "", embed: Discord::Embed.new(
        title: "**failed to execute: #{command}**".upcase,
        colour: 0xdd2e44,
        description: "`#{output.to_s}`"
      ))
    end
  rescue e
    LOG.error "Failed to deliver #{result} message to #{channel_id}: #{e}"
  end

  LOG.info(
    "Loaded #{Commands.registry.size} commands."
  )
end
