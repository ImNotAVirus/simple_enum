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
- **simple**: the use of the library has been designed to be as simple as possible
for a developer to use. In addition to providing Enums, it automatically defines their
[types](guides/enum_types.md), [helpers and guards](guides/helpers.md).

## Installation

The package can be installed by adding `simple_enum` to your list of dependencies
in `mix.exs`:

```elixir
# my_app/mix.exs
def deps do
  [
    {:simple_enum, "~> 1.0"}
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

iex> MyEnums.color_keys()
[:blue, :green, :red]
iex> MyEnums.color_values()
[0, 1, 2]
iex> MyEnums.color_enumerators()
[blue: 0, green: 1, red: 2]

iex> MyEnums.is_color(:blue)
true
iex> MyEnums.is_color(:nope)
false
iex> MyEnums.is_color_key(:blue)
true
iex> MyEnums.is_color_key(0)
false
iex> MyEnums.is_color_value(0)
true
iex> MyEnums.is_color_value(:blue)
false
```

<!-- MDOC !-->

Full documentation can be found at [https://hexdocs.pm/simple_enum](https://hexdocs.pm/simple_enum).

## Known Issues

### Slow compilation on Elixir 1.17 – 1.19

Elixir 1.17 introduced a gradual set-theoretic type checker that suffers from
combinatorial explosion (BDD blowup) when analyzing guards with large `in` lists.
Since SimpleEnum generates `defguard` macros using `value in keys or value in values`,
projects with many enums or enums with many values can experience significantly
slower compilation times on these versions.

In our benchmarks, compiling 100 enums of 10 values took **~15s** on Elixir 1.19
versus **~3.5s** on Elixir 1.20.

**This is fixed in Elixir 1.20** thanks to a rewrite of the type checker internals
from DNF to BDD representation, with further optimizations using lazy BDDs.

**References:**

- [Lazy BDDs with eager literal differences](https://elixir-lang.org/blog/2026/03/19/lazy-bdds-with-eager-literal-differences/) — Official blog post explaining the problem and the fix
- [elixir-lang/elixir#14693](https://github.com/elixir-lang/elixir/pull/14693) — BDD rewrite for maps, tuples, lists
- [elixir-lang/elixir#14806](https://github.com/elixir-lang/elixir/pull/14806) — Lazy BDD structures for all types

## Copyright and License

Copyright (c) 2021 DarkyZ aka NotAVirus.

SimpleEnum source code is licensed under the [MIT License](LICENSE.md).
