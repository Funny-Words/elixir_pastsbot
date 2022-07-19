defmodule Pastsbot.WSClient do
  use WebSockex
  alias Pastsbot.WSClient.Payload, as: Payload
  require Logger

  @websocket_server "wss://gateway.discord.gg/?v=10&encoding=json"

  def start_link(opts \\ []) do
    {_, pastsbot_pid} = Pastsbot.Storage.read
    state = %{:pastes => pastsbot_pid}
    pid = get_pid(WebSockex.start_link(@websocket_server, __MODULE__, state, opts))
    pid.()
  end

  def get_pid(pid) do
    if pid do
      pid_ = pid
      fn -> pid_ end
    else
      fn -> nil end
    end
  end

  # -------------- SERVER CALLBACKS -------------------

  def handle_connect(_conn, state) do
    Logger.info("Connection established")
    {:ok, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnected with reason: #{inspect reason}")
    Pastsbot.Storage.write(state[:pastes])
    {:ok, state}
  end

  def handle_frame({:text, frame}, state) do
    Logger.info("Frame received #{frame}")
    payload = Jason.decode!(frame)
    op = payload["op"]

    cond do
      op == Payload.opcode(:hello) ->
        handle_hello(payload)
      op == Payload.opcode(:dispatch) ->
        handle_dispatch(payload, state)
      true ->
        Logger.info("Unknon frame: #{op}")
    end
    {:ok, state}
  end

  def terminate(reason, state) do
    Logger.warning("#{__MODULE__} was terminated with the reason: #{reason}")
    {:ok, state}
  end

   # Sends JSON-encoded data to the socket
  defp send(data) do
    pid = get_pid(nil)
    Logger.info("Sending data: #{data} to the socket")
    WebSockex.send_frame(pid.(), data)
  end

  # Handles hello
  defp handle_hello(payload) do
    Logger.info("Hello(10) payload received")
    setup_heartbeat(payload)
    System.get_env("TOKEN")
    |> Payload.identify()
    |> send()
  end

  # Sets heartbeat
  defp setup_heartbeat(payload) do
    interval = payload["d"]["heartbeat_interval"] / 1
    spawn(__MODULE__, :send_heartbeat, [interval])
  end

  # Send heartbeat
  def send_heartbeat(interval) do
    send(Payload.heartbeat)
    Logger.info("Heartbeat sent")
    Process.sleep(interval)
    send_heartbeat(interval)
  end

  # Handles dispatch
  defp handle_dispatch(payload, state) do
    event = payload["t"]
    data = payload["d"]

    cond do
      event == "READY" ->
        handle_ready(data)
      event == "MESSAGE_CREATE" ->
        handle_message_create(data, state)
    end
  end

  # Handles ready event
  defp handle_ready(data) do
    Logger.info("Logged in")
    System.put_env(%{"ID" => data["user"]["id"]})
  end

  defp handle_message_create(data, state) do
    prefix = System.get_env("PREFIX")
    if data["author"]["id"] == System.get_env("ID") do
      message = data["content"]
      if String.starts_with?(message, prefix) do
        [cmd, name, paste] = message
        |> String.trim_leading(prefix)
        |> String.split(" ", parts: 3)

        Pastsbot.Commands.handle_commands([data["channel_id"], data["id"]], [cmd, name, paste], state[:pastes])
      end
    end
  end
end
