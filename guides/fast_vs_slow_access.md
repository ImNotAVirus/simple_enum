# Fast vs Slow access

Enumerations access can be resolved in 2 different ways:

- At the compilation (also called **Fast access**)
- At the runtime (also called **Slow access**)

## Fast access

When it's possible, SimpleEnum will try to replace Enum access directly
with it's value (Fast access).  
In order to do this, all arguments given to the Enum access must be resolvable
at the compile time.

To check this behaviour, let's write a simple function to inspect AST of an Enum
named `color`.

    iex> defmodule EnumInspector do
    ...>   def inspect_ast(quoted_expr, env) do
    ...>     quoted_expr
    ...>     |> Macro.postwalk(&expand_enum_ast(&1, env))
    ...>     |> Macro.to_string()
    ...>     |> IO.puts
    ...>   end
    ...>
    ...>   # Expand only the Enum's AST
    ...>   defp expand_enum_ast({:color, [], _} = x, env), do: Macro.expand(x, env)
    ...>   defp expand_enum_ast(x, _), do: x
    ...> end

Now, let's use this module and see how Elixir compile an Enum access with known
arguments at compile time :

    iex> defmodule MyApp.Enums do
    ...>   import SimpleEnum, only: [defenum: 2]
    ...> 
    ...>   # Define the Enum
    ...>   defenum :color, [:blue, :green, :red]
    ...> 
    ...>   # Inspect the generated AST
    ...>   EnumInspector.inspect_ast(quote do
    ...>     dep test() do
    ...>       color(:red, :value)
    ...>     end
    ...>   end, __ENV__)
    ...> end

    dep(test()) do
      2
    end

We notice that the Enum access `color(:red, :value)` has been automatically replaced
with `2` by the compiler.

This explain why Fast access can be used in guards for example.

**NOTE**: [Module attributes](https://elixir-lang.org/getting-started/module-attributes.html#as-constants)
are also supported with fast access.

## Slow access

Now let's take a look at what happens when the values cannot be determined at compile
time.

    iex> defmodule MyApp.Enums do
    ...>   import SimpleEnum, only: [defenum: 2]
    ...>
    ...>   # Define the Enum
    ...>   defenum :color, [:blue, :green, :red]
    ...>
    ...>   # Inspect the generated AST
    ...>   EnumInspector.inspect_ast(quote do
    ...>       dep test(value) do
    ...>           color(value, :value)
    ...>       end
    ...>   end, __ENV__)
    ...> end

    dep(test(value)) do
      case({value, :value}) do
        {x, :key} when x in [:blue, :green, :red] ->
          x
        {x, :value} when x in [0, 1, 2] ->
          x
        {x, :key} when x in [0, 1, 2] ->
          Map.fetch!(%{0 => :blue, 1 => :green, 2 => :red}, x)
        {x, :value} when x in [:blue, :green, :red] ->
          Keyword.fetch!([blue: 0, green: 1, red: 2], x)
        {x, :tuple} when x in [:blue, :green, :red] ->
          {x, Keyword.fetch!([blue: 0, green: 1, red: 2], x)}
        {x, :tuple} when x in [0, 1, 2] ->
          {Map.fetch!(%{0 => :blue, 1 => :green, 2 => :red}, x), x}
        {_, t} when t not in [:key, :value, :tuple] ->
          raise(ArgumentError, "invalid type :value. Expected one of [:key, :value, :tuple]")
        {x, _} ->
          raise(ArgumentError, "invalid value {:value, [], MyApp.Enums} for Enum MyApp.Enums.color/2. Expected one of [:blue, :green, :red, 0, 1, 2]\n")        
      end
    end

This time, the `color(value, :value)` access has been transformed into a big `case`
checking at runtime the value of the arguments given to the Enum.

_It is therefore recommended, when it is possible, to avoid creating temporary variables
in order to store arguments for an Enum access._
