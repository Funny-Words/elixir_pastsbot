defmodule Pastsbot.PasteAgent do
  import Pastsbot.Utils, only: [is_paste: 1]

  # Sets initial value
  def new(pastes \\ %{"ping" => "pong"}) do
    Agent.start_link(fn -> pastes end)
  end

  # Adds new paste to the pastes
  def add(pid, paste) when is_paste(paste) do
    Agent.get_and_update(pid, fn pastes -> Map.put(pastes, paste["name"], paste["content"]) end)
  end

  # Sets new pastes
  def set(pid, pastes) when is_map(pastes) do
    Agent.update(pid, fn _pasts -> pastes end)
  end

  # Gets all pastes
  def get_all(pid) do
    Agent.get(pid, fn pastes -> pastes end)
  end

  # Gets paste by name
  def get(pid, name) when is_binary(name) do
    Agent.get(pid, fn pastes -> pastes[name] end)
  end

  # Removes paste by name
  def remove(pid, name) when is_binary(name) do
    Agent.get_and_update(pid, fn pastes -> Map.delete(pastes, name) end)
  end

  # Updates paste by name with new content
  def update(pid, paste) when is_paste(paste) do
    elem(
      Agent.get_and_update(pid, fn pastes ->
        Map.get_and_update(pastes, paste["name"], &{&1, paste["content"]})
      end),
      1
    )
  end
end
