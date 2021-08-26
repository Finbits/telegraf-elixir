defmodule Telegraf.Serializer.LineProtocolTest do
  use ExUnit.Case, async: true

  alias Telegraf.Metric
  alias Telegraf.Serializer.LineProtocol

  describe "serialize/1" do
    test "works" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather,location=us-midwest temperature=82i 1465839830100400200\n"

      assert actual == expected
    end

    test "ignore field_set nils" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: nil},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather,location=us-midwest 1465839830100400200\n"

      assert actual == expected
    end

    test "ignore tag_set nils" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: nil},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather temperature=82i 1465839830100400200\n"

      assert actual == expected
    end

    test "ignore nils" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: nil},
        field_set: %{temperature: nil},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather 1465839830100400200\n"

      assert actual == expected
    end

    test "float" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 85.7},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather,location=us-midwest temperature=85.7 1465839830100400200\n"

      assert actual == expected
    end

    test "true" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: true},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather,location=us-midwest temperature=true 1465839830100400200\n"

      assert actual == expected
    end

    test "false" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: false},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather,location=us-midwest temperature=false 1465839830100400200\n"

      assert actual == expected
    end

    test "string" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: "27 c"},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us-midwest temperature="27 c" 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "multiple" do
      metric = %Metric{
        name: "weather",
        tag_set: %{another: 27, location: "us-midwest", doctor: "john"},
        field_set: %{bring: "back", temperature: 82, another: false},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])

      expected =
        ~S(weather,another=27,doctor=john,location=us-midwest another=false,bring="back",temperature=82i 1465839830100400200) <>
          "\n"

      assert actual == expected
    end

    test "field values escape" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: ~S(27 "c)},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us-midwest temperature="27 \"c" 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "measurement with space" do
      metric = %Metric{
        name: "wea ther",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(wea\ ther,location=us-midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "measurement with comma" do
      metric = %Metric{
        name: "wea,ther",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(wea\,ther,location=us-midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "tag keys with commas" do
      metric = %Metric{
        name: "weather",
        tag_set: %{"nothing,location" => "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])

      expected =
        ~S(weather,nothing\,location=us-midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "tag keys with equal signs" do
      metric = %Metric{
        name: "weather",
        tag_set: %{"nothing=location" => "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])

      expected =
        ~S(weather,nothing\=location=us-midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "tag keys with spaces" do
      metric = %Metric{
        name: "weather",
        tag_set: %{"nothing location" => "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])

      expected =
        ~S(weather,nothing\ location=us-midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "tag values with commas" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us,midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us\,midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "tag values with equal signs" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us=midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us\=midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "tag values with spaces" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us midwest"},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us\ midwest temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "field keys with commas" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{"foo,temperature" => 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us-midwest foo\,temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "field keys with equal signs" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{"foo=temperature" => 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = ~S(weather,location=us-midwest foo\=temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "field keys with spaces" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{"foo temperature" => 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])

      expected = ~S(weather,location=us-midwest foo\ temperature=82i 1465839830100400200) <> "\n"

      assert actual == expected
    end

    test "no tags" do
      metric = %Metric{
        name: "weather",
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather temperature=82i 1465839830100400200\n"

      assert actual == expected
    end

    test "empty tags" do
      metric = %Metric{
        name: "weather",
        tag_set: %{},
        field_set: %{temperature: 82},
        timestamp: 1_465_839_830_100_400_200
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather temperature=82i 1465839830100400200\n"

      assert actual == expected
    end

    test "no timestamp" do
      metric = %Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82}
      }

      actual = LineProtocol.serialize([metric])
      expected = "weather,location=us-midwest temperature=82i\n"

      assert actual == expected
    end

    test "multiple metrics" do
      metric1 = %Metric{
        name: "weather1",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82}
      }

      metric2 = %Metric{
        name: "weather2",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82}
      }

      actual = LineProtocol.serialize([metric1, metric2])

      expected =
        "weather1,location=us-midwest temperature=82i\nweather2,location=us-midwest temperature=82i\n"

      assert actual == expected
    end

    test "mixed atom string keys" do
      metric = %Metric{
        name: "weather1",
        tag_set: %{:location => "us-midwest", "nothing location" => "us-midwest"},
        field_set: %{temperature: 82}
      }

      actual = LineProtocol.serialize([metric])

      expected =
        ~S(weather1,location=us-midwest,nothing\ location=us-midwest temperature=82i) <> "\n"

      assert actual == expected
    end
  end
end
