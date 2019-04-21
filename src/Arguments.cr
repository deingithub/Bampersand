module Arguments
  extend self

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

  def assert_count(args, count)
    raise "Missing arguments" if args.size < count
  end
end
