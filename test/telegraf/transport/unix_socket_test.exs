defmodule Telegraf.Transport.UnixSocketTest do
  use ExUnit.Case, async: true

  alias Telegraf.Transport.UnixSocket

  describe "children/2" do
    test "invalid socket path" do
      message =
        "invalid configuration given to Telegraf.Transport.UnixSocket.children/2," <>
          " invalid value for :socket_path option: expected string, got: :invalid"

      assert_raise ArgumentError, message, fn ->
        UnixSocket.children(MyTelegraf, socket_path: :invalid)
      end
    end

    test "invalid pool size" do
      message =
        "invalid configuration given to Telegraf.Transport.UnixSocket.children/2," <>
          " invalid value for :pool_size option: expected positive integer, got: :invalid"

      assert_raise ArgumentError, message, fn ->
        UnixSocket.children(MyTelegraf, pool_size: :invalid)
      end
    end
  end
end
