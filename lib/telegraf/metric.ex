defmodule Telegraf.Metric do
  @moduledoc """
  Struct represeting a metric in Telegraf.
  Checkout the [telegraf documentation](https://docs.influxdata.com/telegraf/v1.18/concepts/metrics/) for more details.

  ## Usage

      %Telegraf.Metric{
        name: "weather",
        tag_set: %{location: "us-midwest"},
        field_set: %{temperature: 82},
        timestamp: System.os_time()
      }

  """

  @enforce_keys [:name, :field_set]
  defstruct name: nil, tag_set: %{}, field_set: nil, timestamp: nil

  @type t :: %__MODULE__{
          name: String.t(),
          tag_set: map(),
          field_set: map(),
          timestamp: integer() | nil
        }
end
