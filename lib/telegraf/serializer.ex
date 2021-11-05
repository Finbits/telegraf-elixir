defmodule Telegraf.Serializer do
  @moduledoc """
  Defines a serializer.

  The telegraf daemon supports a variety of [input data formats](https://docs.influxdata.com/telegraf/v1.18/data_formats/input/).
  A serializer is responsible to serialize the metrics into a input data format.
  """

  @doc """
  Serialize a list of metrics into the input data format expected by the transport.
  """
  @callback serialize(metrics :: [Telegraf.Metric.t()]) :: binary()
end
