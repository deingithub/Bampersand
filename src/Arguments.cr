module Arguments
  # These are some helpers for converting string arguments to useful values
  # and asserting their validity at the same time
  extend self

  def assert_count(args, count)
    raise "Missing arguments" if args.size < count
  end

  # Prefer using this method for commands
  # Example: target_user = Arguments.at_position(args, 0, :user)
  # This will either give you a valid user to work with or raise.
  def at_position(args, position, type)
    raise "Missing #{type} argument at #{position}" unless args[position]?
    case type
    when :channel
      to_channel(args[position])
    when :user
      to_user(args[position])
    when :role
      to_role(args[position])
    else
      raise "this can't happen luckily"
    end
  end

  def to_channel(input)
    begin
      input = input.delete("<#>").to_u64
      channel = CACHE.resolve_channel(input)
    rescue e
      LOG.error("to_channel failed to resolve #{input}")
      raise "Invalid channel" if channel.nil?
    end
    channel.not_nil!
  end

  def to_user(input)
    begin
      input = input.delete("<@!>").to_u64
      user = CACHE.resolve_user(input)
    rescue e
      LOG.error("to_user failed to resolve #{input}")
      raise "Invalid user" if user.nil?
    end
    user.not_nil!
  end

  def to_role(input)
    begin
      input = input.delete("<@&>").to_u64
      role = CACHE.resolve_role(input)
    rescue e
      LOG.error("to_role failed to resolve #{input}")
      raise "Invalid role" if role.nil?
    end
    role.not_nil!
  end
end
