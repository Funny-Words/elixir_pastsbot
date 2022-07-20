defmodule Pastsbot.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Pastsbot.WSClient, name: WS},
      {Pastsbot.Paste, name: Paste}
    ]


    opts = [strategy: :one_for_one, name: Pastsbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
