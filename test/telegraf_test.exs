defmodule TelegrafTest do
  use ExUnit.Case
  doctest Telegraf

  describe "start_link/1" do
    test "missing name" do
      message =
        "invalid configuration given to Telegraf.start_link/1," <>
          " required :name option not found, received options: []"

      assert_raise ArgumentError, message, fn ->
        Telegraf.start_link([])
      end
    end

    test "invalid serializer" do
      message =
        "invalid configuration given to Telegraf.start_link/1," <>
          " invalid value for :serializer option: expected atom, got: \"invalid\""

      assert_raise ArgumentError, message, fn ->
        Telegraf.start_link(name: MyTelegraf, serializer: "invalid")
      end
    end

    test "invalid transport" do
      message =
        "invalid configuration given to Telegraf.start_link/1," <>
          " invalid value for :transport option: expected atom, got: \"invalid\""

      assert_raise ArgumentError, message, fn ->
        Telegraf.start_link(name: MyTelegraf, transport: "invalid")
      end
    end
  end

  describe "send/3" do
    test "success", context do
      tmp_dir = create_tmp_dir!(context)
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
         name: client_name,
         transport: Telegraf.Transport.UnixSocket,
         transport_options: [
           socket_path: socket_path,
           pool_size: 1
         ]}
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

  defp create_tmp_dir!(context) do
    module = escape_path(inspect(context.module))
    name = escape_path(to_string(context.test))
    path = ["tmp", module, name] |> Path.join() |> Path.expand()
    File.rm_rf!(path)
    File.mkdir_p!(path)

    path
  end

  @escape Enum.map(' [~#%&*{}\\:<>?/+|"]', &<<&1::utf8>>)

  defp escape_path(path) do
    String.replace(path, @escape, "-")
  end
end
