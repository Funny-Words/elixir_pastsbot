defmodule Pastsbot.Storage do
  @path System.get_env("JSON_PATH", "./pastes.json")

  def read do
    try do
      @path |> File.read!()
    rescue
      true ->
        new()
        read()
    end
    |> Jason.decode!()
  end

  def write do
    File.write(
      @path,
      Pastsbot.Paste.get_all() |> Jason.encode!()
    )
  end

  def new do
    File.write(@path, "{\"ping\": \"pong\"}")
  end
end
