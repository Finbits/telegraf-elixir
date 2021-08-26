defmodule Telegraf.Serializer do
  @callback serialize(metrics :: Telegraf.Metric.t()) :: binary()
end
