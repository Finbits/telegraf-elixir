defmodule Telegraf.Serializer.LineProtocol do
  @moduledoc """
  Serializer for the InfluxDB Line Protocol output data format.

  InfluxData recommends this data format unless another format is required for interoperability.

  https://docs.influxdata.com/telegraf/v1.18/data_formats/output/influx/
  """
  @behaviour Telegraf.Serializer

  alias Telegraf.Metric

  @impl Telegraf.Serializer
  def serialize(metrics) when is_list(metrics) do
    metrics
    |> Enum.map(fn %Metric{} = metric ->
      [
        encode_name(metric.name),
        metric.tag_set |> reject_nils() |> encode_tag_set(),
        metric.field_set |> reject_nils() |> encode_field_set(),
        encode_timestamp(metric.timestamp),
        ?\n
      ]
    end)
    |> IO.iodata_to_binary()
  end

  defp encode_name(name) when is_binary(name) do
    String.replace(name, ~r/[\s,]/, &~s/\\#{&1}/)
  end

  defp encode_tag_set([]), do: []

  defp encode_tag_set(tag_set) do
    tags =
      tag_set
      |> Enum.map(fn {k, v} -> [escape(to_string(k)), ?=, escape(to_string(v))] end)
      |> Enum.intersperse(?,)

    [?,, tags]
  end

  defp encode_field_set([]), do: []

  defp encode_field_set(field_set) do
    fields =
      field_set
      |> Enum.map(fn {k, v} -> [escape(to_string(k)), ?=, encode_field_value(v)] end)
      |> Enum.intersperse(?,)

    [?\s, fields]
  end

  defp encode_timestamp(nil), do: []

  defp encode_timestamp(timestamp) when is_integer(timestamp) do
    [?\s, to_string(timestamp)]
  end

  defp encode_field_value(value) when is_integer(value), do: [to_string(value), ?i]
  defp encode_field_value(value) when is_float(value), do: to_string(value)
  defp encode_field_value(value) when is_boolean(value), do: to_string(value)

  defp encode_field_value(value) when is_binary(value) do
    [?", String.replace(value, ~S("), ~S(\")), ?"]
  end

  defp escape(value) do
    String.replace(value, ~r/[\s,=]/, &~s/\\#{&1}/)
  end

  defp reject_nils(map) when is_map(map) do
    Enum.reject(map, &match?({_k, nil}, &1))
  end
end
