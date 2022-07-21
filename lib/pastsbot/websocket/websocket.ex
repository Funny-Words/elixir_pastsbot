defmodule Pastsbot.WSClient do
  use WebSockex
  require Logger
  alias Pastsbot.Storage
  alias Pastsbot.WSClient.Payload, as: Payload

  @heartbeat_interval 41250
  @websocket_server "wss://gateway.discord.gg/?v=10&encoding=json"

  def start_link(opts) do
    WebSockex.start_link(@websocket_server, __MODULE__, %{}, opts)
  end

  # -------------- GENSERVER CALLBACKS -------------------

  def handle_connect(_conn, state) do
    Logger.info("Connection established")
    {:ok, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnected with reason: #{inspect(reason)}")
    Storage.write()
    {:ok, state}
  end

  def handle_frame({:text, frame}, state) do
    payload = Jason.decode!(frame)
    op = payload["op"]

    cond do
      op == Payload.opcode(:hello) ->
        handle_hello(payload, state)

      op == Payload.opcode(:dispatch) ->
        handle_dispatch(payload, state)

      op == Payload.opcode(:invalid_session) ->
        Logger.warning("Invalid session. Did you set the token env variable?")
        Process.sleep(2000)
        {:reply, send_identify(), state}

      op == Payload.opcode(:ack) ->
        Logger.debug("Ack received")
        {:ok, state}

      true ->
        Logger.debug("Unknown frame: #{op}")
        {:ok, state}
    end
  end

  def handle_cast({:heartbeat}, state) do
    Logger.debug("Sending heartbeat")
    frame = {:text, Payload.heartbeat()}
    {:reply, frame, state}
  end

  def handle_info(:heartbeat, state) do
    WebSockex.cast(WS, {:heartbeat})
    Process.send_after(self(), :heartbeat, @heartbeat_interval)
    {:ok, state}
  end

  def handle_terminate_close(reason, _parent, _debug, _state) do
    Logger.info("#{reason}")
    Storage.write()
  end

  def terminate(reason, state) do
    Logger.critical("Connection was terminated with the reason: #{inspect(reason)}")
    Storage.write()
    {:ok, state}
  end

  # ------------------- FUNCTIONS -----------------
  #
  # Handles hello
  defp handle_hello(_payload, state) do
    Logger.debug("Hello(10) payload received")
    Process.send_after(self(), :heartbeat, @heartbeat_interval)

    {:reply, send_identify(), state}
  end

  defp send_identify() do
    frame =
      System.get_env("TOKEN")
      |> Payload.identify()

    {:text, frame}
  end

  # Handles dispatch
  defp handle_dispatch(payload, state) do
    event = payload["t"]
    data = payload["d"]

    cond do
      event == "READY" ->
        handle_ready(data, state)

      event == "MESSAGE_CREATE" ->
        handle_message_create(data, state)

      true ->
        {:ok, state}
    end
  end

  # Handles ready event
  defp handle_ready(data, state) do
    Logger.info("Logged in")
    System.put_env(%{"ID" => data["user"]["id"]})
    {:ok, state}
  end

  defp handle_message_create(data, state) do
    prefix = System.get_env("PREFIX", "$")

    if data["author"]["id"] == System.get_env("ID") do

      if String.starts_with?(data["content"], prefix) do
        msg =
          data["content"]
          |> String.trim_leading(prefix)
          |> String.split(" ", parts: 3)

        [cmd | tail] = msg
        name = if length(msg) > 1, do: hd(tail), else: nil
        paste = if length(msg) == 3, do: List.last(msg), else: nil
        Logger.debug("Command #{cmd} - #{name} - #{paste} called")

        Pastsbot.Commands.handle_commands([data["channel_id"], data["id"]], [cmd, name, paste])
      end
    end

    {:ok, state}
  end
end
