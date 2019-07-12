# Bampersand

Simple Utility Bot for Discord written in Crystal and discordcr. See [the project wiki](https://git.15318.de/Dingens/Bampersand/wiki) for documentation.

## Development

Adapt `.env.example` to your needs and rename it to `.env`. It's gitignored by default. Create a sqlite3 database called `bampersand.sqlite3` with the following tables:  
 1. `create table state (guild_id unsigned integer unique on conflict replace, features unsigned integer, mirror_in unsigned integer, mirror_out unsigned integer, board_emoji string, board_channel unsigned integer, board_min_reacts unsigned integer, join_channel unsigned integer, join_text string, leave_channel unsigned integer, leave_text string);`
 2. `create table board (source_message unsigned integer unique on conflict replace, board_message unsigned integer);`
 3. `create table tags (guild_id unsigned integer, name string, content string, constraint yikes unique (guild_id, name) on conflict replace);`
 4. `create table slowmodes (channel_id unsigned integer unique on conflict replace, secs unsigned integer);`
 5. `create table warnings (guild_id unsigned integer, user_id unsigned integer, mod_id unsigned integer, text string, timestamp date default current_timestamp);`
 6. `create table perms (guild_id unsigned integer unique on conflict replace, admin_id unsigned integer, moderator_id unsigned integer);`

## Contributing

This project is located on [Gitea](https://git.15318.de/Dingens/Bampersand/) and all commits are mirrored to [GitLab](https://gitlab.com/deing/bampersand) and [GitHub](https://github.com/deingithub/Bampersand) for discoverability and easier contributions. The issue tracker is exclusively on Gitea.

1. Log in on Gitea using your favourite platform and fork *or* fork directly from your favourite platform.
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Please follow the guidelines in CONTRIBUTING.md.

## Contributors

- [deing](https://gitlab.com/deing) - creator and maintainer
