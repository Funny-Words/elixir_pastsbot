defmodule Pastsbot.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Finch, name: FinchClient},
      {Pastsbot.WSClient, name: WSC}
    ]

    opts = [strategy: :one_for_one, name: Pastsbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
 end
