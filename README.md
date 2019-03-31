# Bampersand

Simple Utility Bot for Discord written in Crystal and discordcr. See https://15318.de/bampersand for documentation.

## Development

Requires this configuration file being available:  
`config.ini`
```
[foundation]
token = discord-token-here
client = discord-client-id
prefix = whatever
admin = your-discord-id
```
and a sqlite3 database called `bampersand.sqlite3` with the following tables:  
 1. `create table state (guild_id unsigned integer unique on conflict replace, features unsigned integer, mirror_in unsigned integer, mirror_out unsigned integer, board_emoji string, board_channel unsigned integer, board_min_reacts unsigned integer);`
 2. `create table board (source_message unsigned integer unique on conflict replace, board_message unsigned integer);`

## Contributing

1. Fork it (<https://gitlab.com/deing/Bampersand/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [deing](https://gitlab.com/deing) - creator and maintainer
