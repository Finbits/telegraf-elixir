defmodule TelegrafTest do
  use ExUnit.Case
  doctest Telegraf

  describe "send/3" do
    @tag :tmp_dir
    test "success", %{tmp_dir: tmp_dir} do
      socket_path = Path.join(tmp_dir, "telegraf.sock")

      server_name = Module.concat(__MODULE__, Server)
      client_name = Module.concat(__MODULE__, Client)
      pid = self()
      on_message = fn message -> send(pid, {:new_message, message}) end
      on_start = fn -> send(pid, {:socket_started, socket_path}) end

      start_supervised!(
        {Telegraf.FakeUnixSocket,
         name: server_name, socket_path: socket_path, on_message: on_message, on_start: on_start}
      )

      assert_receive {:socket_started, ^socket_path}

      start_supervised!(
        {Telegraf,
         transport: Telegraf.Transport.UnixSocket,
         socket_path: socket_path,
         pool_size: 1,
         name: client_name}
      )

      metric = %Telegraf.Metric{
        name: "weather",
        tag_set: %{location: "us-midwest", season: "summer"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      Telegraf.send(client_name, metric)

      assert_receive {:new_message, message}

      assert message ==
               "weather,location=us-midwest,season=summer temperature=82i 1465839830100400200\n"
    end
  end
end
