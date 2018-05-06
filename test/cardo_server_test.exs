defmodule CardoServerTest do
  use ExUnit.Case
  doctest CardoServer

  test "greets the world" do
    assert CardoServer.hello() == :world
  end
end
