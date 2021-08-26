defmodule TelegrafTest do
  use ExUnit.Case
  doctest Telegraf

  test "greets the world" do
    assert Telegraf.hello() == :world
  end
end
