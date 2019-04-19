Commands.register_command("hulp") do |args, ctx|
  next "Ffs\nDon't do that again <@#{ctx.issuer.id}>. Look at my flair\nI only need 0.001% of my power to wipe you out" unless Perms.check(ctx.guild_id, ctx.issuer.id, Perms::Level::Operator)
  true
end
