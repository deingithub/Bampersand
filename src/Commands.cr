require "./commands/*"

module Commands
  extend self
  alias CommandType = Proc(Array(String), CommandContext, CommandResult)
  alias CommandContext = NamedTuple(
    issuer: Discord::User,
    client: Discord::Client,
    channel_id: UInt64,
    guild_id: UInt64?)
  alias CommandResult = NamedTuple(title: String, text: String) | String
  alias CommandInfo = NamedTuple(fun: CommandType, desc: String)
  @@COMMANDS = {} of String => CommandInfo

  def register_command(name, desc, &execute : Array(String), CommandContext -> CommandResult)
    @@COMMANDS[name] = {fun: execute, desc: desc}
  end

  def get_commands
    @@COMMANDS
  end

  def contextualize(msg : Discord::Message)
    client = Bampersand::CLIENT
    guild = msg.guild_id
    return {
      issuer:     msg.author,
      client:     client,
      channel_id: msg.channel_id.to_u64,
      guild_id:   guild.to_u64,
    } unless guild.nil?
    {
      issuer:     msg.author,
      client:     client,
      channel_id: msg.channel_id.to_u64,
      guild_id:   nil,
    }
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
      output = @@COMMANDS[command][:fun].call(
        arguments, contextualize(msg)
      )
      send_result(client, msg.channel_id, command, :success, output)
    rescue e
      send_result(client, msg.channel_id, command, :error, e)
      Log.error "Failed to execute: #{e}"
    end
  end

  def send_result(client, channel_id, command, result, output)
    begin
      if result == :success
        if output.is_a?(String)
          client.create_message(channel_id, "", embed: Discord::Embed.new(
            colour: 0x16161d, description: output.to_s
          ))
        elsif output.is_a?(NamedTuple(title: String, text: String))
          client.create_message(channel_id, "", embed: Discord::Embed.new(
            colour: 0x16161d, description: output[:text], title: output[:title]
          ))
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
end
