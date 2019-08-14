create table state (
  guild_id unsigned integer unique on conflict replace,
  features unsigned integer,
  mirror_in unsigned integer,
  mirror_out unsigned integer,
  board_emoji string,
  board_channel unsigned integer,
  board_min_reacts unsigned integer,
  join_channel unsigned integer,
  join_text string,
  leave_channel unsigned integer,
  leave_text string
);
create table board (
  source_message unsigned integer unique on conflict replace,
  board_message unsigned integer
);
create table tags (
  guild_id unsigned integer,
  name string, content string,
  constraint yikes unique (guild_id, name) on conflict replace
);
create table slowmodes (
  channel_id unsigned integer unique on conflict replace,
  secs unsigned integer
);
create table warnings (
  guild_id unsigned integer,
  user_id unsigned integer,
  mod_id unsigned integer,
  text string,
  timestamp date default current_timestamp
);
create table perms (
  guild_id unsigned integer unique on conflict replace,
  admin_id unsigned integer,
  moderator_id unsigned integer
);
create table killfile (
  guild_id unique on conflict replace
);
create table role_kiosks (
  message_id unsigned integer unique on conflict replace,
  data string
);