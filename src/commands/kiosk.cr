Commands.register_command("rolekiosk update", "Configure a message as a role kiosk.", Perms::Level::Admin) do |args|
  Arguments.assert_count(args, 2)
  RoleKiosk.update_kiosk(args[0].to_u64, args[1])
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
    text: "| rolekiosk update <message_id emoji|roleid;emoji|roleid;…>
  | rolekiosk delete <message_id>
  | rolekiosk info <message_id>",
    title: "**BAMPERSAND ROLE KIOSK**",
  }
end
