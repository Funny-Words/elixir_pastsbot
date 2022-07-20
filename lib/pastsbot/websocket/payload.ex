defmodule Pastsbot.WSClient.Payload do
  use Bitwise

  def opcode(op) do
    %{
      :dispatch => 0,
      :heartbeat => 1,
      :identify => 2,
      :resume => 6,
      :reconnect => 7,
      :invalid_session => 9,
      :hello => 10,
      :ack => 11
    }[op]
  end

  defp build_payload(op, data, s \\ nil, t \\ nil) do
    %{op: opcode(op), d: data, s: s, t: t} |> Jason.encode!()
  end

  def properties do
    {_, osname} = :os.type()

    %{
      "$os" => osname,
      "$browser" => "furryfox"
    }
  end

  def identify(token) do
    identify = %{
      token: token,
      properties: properties(),
      intents: 1 <<< 9 ||| 1 <<< 12 ||| 1 <<< 15
    }

    build_payload(:identify, identify)
  end

  def heartbeat do
    build_payload(:heartbeat, nil)
  end
end
