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
    return case type
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
      channel = cache!.resolve_channel(input)
    rescue e
      Log.error("to_channel failed to resolve #{input}")
      raise "Invalid channel" if channel.nil?
    end
    channel
  end

  def to_user(input)
    begin
      input = input.delete("<@!>").to_u64
      user = cache!.resolve_user(input)
    rescue e
      Log.error("to_user failed to resolve #{input}")
      raise "Invalid user" if user.nil?
    end
    user
  end

  def to_role(input)
    begin
      input = input.delete("<@&>").to_u64
      role = cache!.resolve_role(input)
    rescue e
      Log.error("to_role failed to resolve #{input}")
      raise "Invalid role" if role.nil?
    end
    role
  end
end
