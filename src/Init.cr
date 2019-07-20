# This is the entry point for the binary.
# It starts the logger and sets a block to run on program shutdown,
# which is supposed to close the DB, before booting the main bot code
# from the Bampersand.cr file.

LOG = Logger.new(STDOUT, level: Logger::DEBUG, progname: "B&")
LOG.info("Initializing…")
Dotenv.load!

require "./Bampersand"

SHUTDOWN = ->(s : Signal) {
  LOG.fatal "Received #{s}"
  Bampersand::DATABASE.close
  LOG.fatal "This program is halting now, checkmate Alan"
  exit 0
}
Signal::INT.trap &SHUTDOWN
Signal::TERM.trap &SHUTDOWN

Bampersand.start
