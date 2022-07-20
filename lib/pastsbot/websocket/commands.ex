defmodule Pastsbot.Commands do
  alias Pastsbot.Paste
  alias Pastsbot.Storage

  @api "https://discord.com/api/v10"

  def handle_commands([channel_id, id], [cmd, name, paste]) do
    cond do
      cmd == "a" ->
        Paste.add(name, paste)
        edit_message("paste added", [channel_id, id])

      cmd == "g" ->
        Paste.get(name)
        |> edit_message([channel_id, id])

      cmd == "r" ->
        Paste.remove(name)
        edit_message("paste removed", [channel_id, id])

      cmd == "u" ->
        Paste.update(name, paste)
        edit_message("paste updated", [channel_id, id])

      cmd == "s" ->
        Storage.write()
        edit_message("pastes saved", [channel_id, id])

      cmd == "ga" ->
        edit_message(
          Paste.get_all_names() |> Enum.join(", "),
          [channel_id, id]
        )

      cmd == "h" ->
        """
        ```
        a [name] [paste] - add paste
        g [name] - get paste by name
        r [name] - remove paste
        u [name] [paste] - update paste
        s - force-save pastes
        ga - get all the paste names
        h - this help message
        ```
        """
        |> edit_message([channel_id, id])

      true ->
        edit_message("invalid command", [channel_id, id])
    end

    {:ok, %{}}
  end

  defp edit_message(data, [channel_id, id]) do
    headers = [Authorization: "#{System.get_env("TOKEN")}", "Content-Type": "application/json"]

    HTTPoison.patch(
      "#{@api}/channels/#{channel_id}/messages/#{id}",
      Jason.encode!(%{"content" => data}),
      headers
    )
  end
end
