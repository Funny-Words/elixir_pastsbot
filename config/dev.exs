import Config

config :logger, :console,
  format: "[$level] - $message $metadata\n",
  level: :debug,
  utc_log: true
