defmodule Pastsbot.Storage do
  alias Pastsbot.PasteAgent

  # Path attribute
  @path System.get_env("JSON_PATH", "./pastes.json")

  # Sets an agent with the read value
  # Returns an Agent pid
  def read do
    @path
    |> File.read!()
    |> Jason.decode!()
    |> PasteAgent.new()
  end

  def write(pid) do
    File.write(
      @path,
      PasteAgent.get_all(pid) |> Jason.encode!()
    )
  end
end
