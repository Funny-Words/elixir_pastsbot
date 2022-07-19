defmodule Pastsbot.Commands do
  alias Pastsbot.PasteAgent
  alias Pastsbot.Storage

  @api "https://discord.com/api/v10"

  def handle_commands([channel_id, id], [cmd, name, paste], state) do
    pastes = state[:pastes]
    cond do
      cmd == "a" ->
        PasteAgent.add(pastes, %{"name" => name, "content" => paste})
        edit_message("paste added", [channel_id, id])
      cmd == "g" ->
        PasteAgent.get(pastes, name)
        |> edit_message([channel_id, id])
      cmd == "r" ->
        PasteAgent.remove(pastes, name)
        edit_message("paste removed", [channel_id, id])
      cmd == "u" ->
        PasteAgent.update(pastes, %{"name" => name, "content" => paste})
        edit_message("paste updated", [channel_id, id])
      cmd == "s" ->
        Storage.write(pastes)
        edit_message("pastes saved", [channel_id, id])
    end
  end

  defp edit_message(data, [channel_id, id]) do
    Finch.build(
      :patch,
      "#{@api}/channels/#{channel_id}/messages/#{id}",
      {:stream, [data]}
    ) |> Finch.request(FinchClient)
  end
end
