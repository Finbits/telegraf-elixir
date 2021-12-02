# Telegraf

<!-- MDOC !-->

Telegraf client.

[![Hex.pm Version](http://img.shields.io/hexpm/v/telegraf.svg?style=flat)](https://hex.pm/packages/telegraf)
[![CI](https://github.com/Finbits/telegraf-elixir/workflows/CI/badge.svg?branch=main)](https://github.com/Finbits/telegraf-elixir/actions?query=branch%3Amain)
[![codecov](https://codecov.io/gh/Finbits/telegraf-elixir/branch/main/graph/badge.svg?token=wiZnjguSRx)](https://codecov.io/gh/Finbits/telegraf-elixir)

[Checkout the documentation](https://hexdocs.pm/telegraf) for more information.

## Installation

The package can be installed by adding `telegraf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:telegraf, "~> 0.1.1"}
  ]
end
```

## Usage

1. Add `Telegraf` to your supervision tree:


```elixir
{Telegraf, name: MyTelegraf}
```

2. Send the metric:

```elixir
metric = %Telegraf.Metric{
  name: "weather",
  tag_set: %{location: "us-midwest"},
  field_set: %{temperature: 82},
  timestamp: System.os_time()
}

Telegraf.send(MyTelegraf, metric)
```

## Changelog

See the [changelog](CHANGELOG.md).

<!-- MDOC !-->

## Contributing

See the [contributing file](CONTRIBUTING.md).


## License

Copyright 2021 (c) Finbits.

telegraf-elixir source code is released under Apache 2 License.

Check [LICENSE](https://github.com/finbits/telegraf/blob/main/LICENSE) file for more information.
