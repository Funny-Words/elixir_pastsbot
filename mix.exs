defmodule Pastsbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :pastsbot,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:websockex, :jason],
      extra_applications: [:logger],
      mod: {Pastsbot.Application, []}
    ]
  end

  defp escript do
    [main_module: Pastsbot.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:websockex, "~> 0.4.3"},
      {:finch, "~> 0.12"}
    ]
  end
end
