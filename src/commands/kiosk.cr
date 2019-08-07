Commands.register_command("rolekiosk update", "Configure a message as a role kiosk.", Perms::Level::Admin) do |args|
  Arguments.assert_count(args, 2)
  location = args[0].split(":")
  channel_id = location[0].to_u64
  message_id = location[1].to_u64

  # If we already have this configured, delete all our old reactions
  old_emoji = RoleKiosk.kiosk(message_id)
  if old_emoji
    old_emoji.keys.each do |emoji|
      bot!.delete_own_reaction(channel_id, message_id, emoji.delete("<>"))
    end
  end
  # Add reaction template
  emojis = args[1].split(";").map { |x| x.split("|")[0] }
  emojis.each do |emoji|
    bot!.create_reaction(channel_id, message_id, emoji.delete("<>"))
  end
  RoleKiosk.update_kiosk(message_id, args[1])
  true
end

Commands.register_command("rolekiosk delete", "Disables a message's role kiosk functionality.", Perms::Level::Admin) do |args|
  Arguments.assert_count(args, 1)
  RoleKiosk.delete_kiosk(args[0].to_u64)
  true
end

Commands.register_command("rolekiosk info", "Displays a role kiosk's current configuration.", Perms::Level::Admin) do |args|
  Arguments.assert_count(args, 1)
  kiosk = RoleKiosk.kiosk(args[0].to_u64)
  raise "Not configured for #{args[0]}" unless kiosk
  {
    title: "**ROLE KIOSK CONFIGURATION**",
    text:  "Message ID: `#{args[0]}`
    #{kiosk.map { |x| "#{x[0]} <@&#{x[1]}>" }.join("\n")}",
  }
end

Commands.register_command("rolekiosk", "[Manage Role Kiosks]", Perms::Level::Admin) do
  {
    text: "| rolekiosk update <channel_id:message_id emoji|roleid;emoji|roleid;…>
  | rolekiosk delete <message_id>
  | rolekiosk info <message_id>",
    title: "**BAMPERSAND ROLE KIOSK**",
  }
end
