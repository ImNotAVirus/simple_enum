# SimpleEnum

[![Hex.pm version](https://img.shields.io/hexpm/v/simple_enum.svg?style=flat)](https://hex.pm/packages/simple_enum)
[![Hex.pm license](https://img.shields.io/hexpm/l/simple_enum.svg?style=flat)](https://hex.pm/packages/simple_enum)
[![Build Status](https://github.com/ImNotAVirus/simple_enum/actions/workflows/tests.yml/badge.svg)](https://github.com/ImNotAVirus/simple_enum/actions/workflows/tests.yml)
[![Coverage Status](https://coveralls.io/repos/github/ImNotAVirus/simple_enum/badge.svg?branch=master)](https://coveralls.io/github/ImNotAVirus/simple_enum?branch=master)

<!-- MDOC !-->

SimpleEnum is a simple library that implements Enumerations in Elixir.

An Enumeration is a user-defined type that consists of a set of several named
constants that are known as Enumerators.  
The purpose of SimpleEnum is to provide an equivalent for the Elixir language.

SimpleEnum is:

- **fast**: being based on a macro system, access to the Enum will be resolved
at compile time when it is possible (see. [Fast vs Slow access](guides/fast_vs_slow_access.md))
- **simple**: The use of the library has been designed to be as simple as possible
for a developer to use. In addition to providing the Enums, it automatically defines their
[types](guides/enum_types.md) and provides an [introspection system](guides/introspection.md).

## Installation

The package can be installed by adding `simple_enum` to your list of dependencies
in `mix.exs`:

```elixir
# my_app/mix.exs
def deps do
  [
    {:simple_enum, "~> 0.1"}
  ]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

Optionally, if you use the formatter, add this line to `.formatter.exs`:

```elixir
# my_app/.formatter.exs
[
  import_deps: [:simple_enum]
]
```

## Basic Usage

``` elixir
iex> defmodule MyEnums do
...>   import SimpleEnum, only: [defenum: 2]
...>
...>   defenum :color, [:blue, :green, :red]
...>   defenum :day, monday: "MON", tuesday: "TUE", wednesday: "WED"
...> end

iex> require MyEnums

iex> MyEnums.color(:blue)
0
iex> MyEnums.color(0)
:blue
iex> MyEnums.day(:monday)
"MON"
iex> MyEnums.day("MON")
:monday
iex> MyEnums.day("MONN")
** (ArgumentError) invalid value "MONN" for Enum MyEnums.day/1. Expected one of [:monday, :tuesday, :wednesday, "MON", "TUE", "WED"]
```

<!-- MDOC !-->

Full documentation can be found at [https://hexdocs.pm/simple_enum](https://hexdocs.pm/simple_enum).

## Copyright and License

Copyright (c) 2021 DarkyZ aka NotAVirus.

SimpleEnum source code is licensed under the [MIT License](LICENSE.md).
