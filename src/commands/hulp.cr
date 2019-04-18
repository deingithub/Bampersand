require "../Commands"
require "../L10N"
require "../Perms"

Commands.register_command("hulp") do |args, ctx|
  perms = case args.shift.downcase
  when "op"
    Perms::Level::Operator
  when "own"
    Perms::Level::Owner
  when "adm"
    Perms::Level::Admin
  when "mod"
    Perms::Level::Moderator
  else
    Perms::Level::User
  end
  Perms.check(ctx[:guild_id], ctx[:issuer].id.to_u64, perms).to_s
end
