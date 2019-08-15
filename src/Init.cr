# This is the entry point for the binary.
# It starts the logger and sets a block to run on program shutdown,
# which is supposed to close the DB, before booting the main bot code
# from the Bampersand.cr file.

require "db"
require "dotenv"
require "logger"
require "sqlite3"

LOG = Logger.new(STDOUT, level: Logger::DEBUG, progname: "B&")
LOG.info("Initializing…")
Dotenv.load!

VERSION  = `shards version`.chomp
STARTUP  = Time.monotonic
DATABASE = DB.open "sqlite3://./bampersand.sqlite3"

SHUTDOWN = ->(s : Signal) {
  LOG.fatal "Received #{s}"
  DATABASE.close
  LOG.fatal "This program is halting now, checkmate Alan"
  exit 0
}
Signal::INT.trap &SHUTDOWN
Signal::TERM.trap &SHUTDOWN

require "./Bampersand"
BOT = Bampersand.boot

CACHE = BOT.cache.not_nil!

# Then, by all means, let there be … life!
BOT.run
