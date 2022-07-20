defmodule Pastsbot.Paste do
  use GenServer

  def start_link(opts) do
    state = Pastsbot.Storage.read()
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    {:ok, state}
  end

  # SERVER

  def handle_call({:get, name}, _from, state) do
    value = state[name]
    {:reply, value, state}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_all_names, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:add, name, paste}, _from, state) do
    {:reply, nil, Map.put(state, name, paste)}
  end

  def handle_call({:remove, name}, _from, state) do
    {:reply, nil, Map.delete(state, name)}
  end

  def handle_call({:update, name, paste}, _from, state) do
    {:reply, nil, Map.update(state, name, "nil", fn _val -> paste end)}
  end

  # CLIENT

  def get(name), do: GenServer.call(Paste, {:get, name})
  def get_all(), do: GenServer.call(Paste, :get_all)
  def get_all_names(), do: GenServer.call(Paste, :get_all_names)
  def add(name, paste), do: GenServer.call(Paste, {:add, name, paste})
  def remove(name), do: GenServer.call(Paste, {:remove, name})
  def update(name, paste), do: GenServer.call(Paste, {:update, name, paste})
end
