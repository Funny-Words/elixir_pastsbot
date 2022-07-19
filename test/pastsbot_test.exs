defmodule PastsbotTest do
  use ExUnit.Case
  doctest Pastsbot

  test "greets the world" do
    assert Pastsbot.hello() == :world
  end
end
