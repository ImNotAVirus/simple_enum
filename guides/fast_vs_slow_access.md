# Fast vs Slow access

`name/1` and `name/2` access can be resolved in 2 different ways:

- At compilation (**fast access**)
- At runtime (**slow access**)

## Fast access

When all arguments are known at compile time, SimpleEnum replaces the
macro call directly with its result. This means zero runtime overhead.

    color(:red)        # compiled as: 2
    color(:red, :key)  # compiled as: :red

This is why fast access can be used in guards and module attributes.

**NOTE**: [Module attributes](https://elixir-lang.org/getting-started/module-attributes.html#as-constants)
are also supported with fast access.

## Slow access

When arguments are only known at runtime (e.g. function parameters,
variables), SimpleEnum generates a `case` expression that performs
the lookup at runtime.

    def lookup(value) do
      color(value)  # compiled as a case expression
    end

_It is therefore recommended, when possible, to avoid creating temporary
variables to store arguments for an Enum access._

## Note about helpers and guards

The fast/slow distinction only applies to `name/1` and `name/2` macros.

Helpers (`name_keys/0`, `name_values/0`, `name_enumerators/0`) are always
resolved at compile time since they take no arguments.

Guards (`is_name/1`, `is_name_key/1`, `is_name_value/1`) expand to
guard-safe expressions at compile time and can be used both in `when`
clauses and in function bodies.
