require "../Commands"

module CommandsCore
  include Commands
  PING = ->(args : Array(String), ctx : CommandContext) {
    ":ping_pong: " + ["Pyongyang!", "Ding!", "Pong!", "[reverberating PONG]", "Plonk."].sample
  }
  HELP = ->(args : Array(String), ctx : CommandContext) {
    acc = ""
    COMMANDS_AND_WHERE_TO_FIND_THEM.each do |(name, data)|
      acc += "| #{name} — #{data[:desc]}\n"
    end
    acc += "Prefix is `#{Bampersand::CONFIG["prefix"]}`. See `about` for more information."
    {title: "**BAMPERSAND COMMANDS**", text: acc}
  }
  ABOUT = ->(args : Array(String), ctx : CommandContext) {
    uptime = Time.monotonic - Bampersand::STARTUP
    text = <<-STR
    This is a simple utility bot for Discord powered by [Crystal](https://crystal-lang.org).
    You can take a peek <:blobpeek:559732380697362482> at the [documentation](https://15318.de/bampersand) and the [source code](https://gitlab.com/deing/bampersand).
    Currently running on #{ctx[:client].cache.as(Discord::Cache).guilds.size} guilds, serving #{ctx[:client].cache.as(Discord::Cache).users.size} users.
    Uptime is #{uptime.days}d #{uptime.hours}h #{uptime.minutes}m #{uptime.seconds}s. Bot operator is <@#{Bampersand::CONFIG["admin"]}>.
    STR
    {title: "**BAMPERSAND VERSION #{Bampersand::VERSION}**", text: text}
  }
end
