defmodule Telegraf.Serializer do
  @moduledoc """
  TODO
  """
  @callback serialize(metrics :: Telegraf.Metric.t()) :: binary()
end
