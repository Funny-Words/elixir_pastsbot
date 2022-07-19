import Config

config :logger, :console,
  format: "[$level] - $message $metadata\n",
  level: :info,
  utc_log: true
