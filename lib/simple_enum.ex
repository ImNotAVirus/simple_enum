defmodule SimpleEnum do
  @moduledoc """
  Documentation for `SimpleEnum`.
  """

  ## Public API

  defmacro defenum(name, kv) do
    quote location: :keep do
      import SimpleEnum,
        only: [
          defenum: 2,
          is_integer_kv: 1,
          is_string_kv: 1,
          int_kv_to_fields: 1,
          str_kv_to_fields: 1
        ]

      @name unquote(name)
      @enum_name "#{inspect(__MODULE__)}.#{@name}"
      @kv unquote(kv)
      @fields unquote(kv_to_fields())
      @keys Keyword.keys(@fields)
      @values Keyword.values(@fields)
      @types [:key, :value, :tuple]

      @fields_rev @fields
                  |> Enum.map(fn {k, v} -> {v, k} end)
                  |> Enum.into(%{})
                  |> Macro.escape()

      # TODO: Check duplicate keys/values (with `@unique true` attribute)
      # -> ValueError: duplicate values found in <enum 'Mistake'>: FOUR -> THREE
      # TODO: defenump

      unquote(types())
      unquote(fast_introspection())
      unquote(fast_defs_arity_1())
      unquote(slow_arity_1())
      unquote(fast_defs_arity_2())
      unquote(slow_arity_2())
    end
  end

  ## Helpers

  defp kv_to_fields() do
    quote unquote: false, location: :keep do
      case @kv do
        [k | _] when is_atom(k) -> int_kv_to_fields(@kv)
        [kv | _] when is_integer_kv(kv) -> int_kv_to_fields(@kv)
        [kv | _] when is_string_kv(kv) -> str_kv_to_fields(@kv)
        [] -> raise ArgumentError, "enum #{@enum_name} cannot be empty"
        _ -> raise ArgumentError, "invalid key/value pairs for enum #{@enum_name}"
      end
    end
  end

  ## Private functions

  defp types() do
    quote unquote: false, location: :keep do
      @type unquote(Macro.var(@name, __MODULE__)) ::
              unquote(Enum.reduce(@keys, &{:|, [], [&1, &2]}))

      # TODO: Add type for enum_keys and enum_values
    end
  end

  defp fast_introspection() do
    quote unquote: false, location: :keep do
      defmacro unquote(@name)(:__keys__), do: unquote(@keys)
      defmacro unquote(@name)(:__values__), do: unquote(@values)
      defmacro unquote(@name)(:__fields__), do: unquote(@fields)
    end
  end

  defp fast_defs_arity_1() do
    quote unquote: false, location: :keep do
      Enum.each(@fields, fn {k, v} ->
        # def name(key), do: value
        defmacro unquote(@name)(unquote(k)), do: unquote(v)
        # def name(value), do: key
        defmacro unquote(@name)(unquote(v)), do: unquote(k)
      end)
    end
  end

  defp slow_arity_1() do
    quote unquote: false, location: :keep, generated: true do
      defmacro unquote(@name)(value) do
        value_error = "invalid value #{inspect(value)} for Enum #{@enum_name}/1"

        quote do
          case unquote(value) do
            :__keys__ -> unquote(@keys)
            :__values__ -> unquote(@values)
            :__fields__ -> unquote(@fields)
            x when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
            x when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
            x -> raise ArgumentError, unquote(value_error)
          end
        end
      end
    end
  end

  defp fast_defs_arity_2() do
    quote unquote: false, location: :keep do
      Enum.each(@fields, fn {k, v} ->
        # def name(key, :key), do: key
        defmacro unquote(@name)(unquote(k), :key), do: unquote(k)
        # def name(key, :value), do: value
        defmacro unquote(@name)(unquote(k), :value), do: unquote(v)
        # def name(key, :tuple), do: {key, value}
        defmacro unquote(@name)(unquote(k), :tuple), do: {unquote(k), unquote(v)}

        # def name(value, :key), do: key
        defmacro unquote(@name)(unquote(v), :key), do: unquote(k)
        # def name(value, :value), do: value
        defmacro unquote(@name)(unquote(v), :value), do: unquote(v)
        # def name(value, :tuple), do: {key, value}
        defmacro unquote(@name)(unquote(v), :tuple), do: {unquote(k), unquote(v)}
      end)
    end
  end

  defp slow_arity_2() do
    quote unquote: false, location: :keep, generated: true do
      defmacro unquote(@name)(value, type) do
        key_error = "invalid type #{inspect(type)}. Expected one of #{inspect(@types)}"
        value_error = "invalid value #{inspect(value)} for Enum #{@enum_name}/2"

        quote do
          case {unquote(value), unquote(type)} do
            {x, :key} when x in unquote(@keys) -> x
            {x, :value} when x in unquote(@values) -> x
            {x, :key} when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
            {x, :value} when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
            {x, :tuple} when x in unquote(@keys) -> {x, Keyword.fetch!(unquote(@fields), x)}
            {x, :tuple} when x in unquote(@values) -> {Map.fetch!(unquote(@fields_rev), x), x}
            {_, t} when t not in unquote(@types) -> raise ArgumentError, unquote(key_error)
            {x, _} -> raise ArgumentError, unquote(value_error)
          end
        end
      end
    end
  end

  ## Internal functions

  defguard is_kv(kv) when is_tuple(kv) and tuple_size(kv) == 2 and is_atom(elem(kv, 0))
  defguard is_integer_kv(kv) when is_kv(kv) and is_integer(elem(kv, 1))
  defguard is_string_kv(kv) when is_kv(kv) and is_binary(elem(kv, 1))

  def int_kv_to_fields(kv) do
    kv
    |> Enum.reduce({[], 0}, fn
      key, {result, counter} when is_atom(key) ->
        {[{key, counter} | result], counter + 1}

      {key, counter} = kv, {result, _} when is_integer_kv(kv) ->
        {[{key, counter} | result], counter + 1}

      value, _ ->
        raise ArgumentError, "invalid key/value pairs: #{inspect(value)}"
    end)
    |> Kernel.elem(0)
    |> Enum.reverse()
  end

  def str_kv_to_fields(kv) do
    kv
    |> Enum.reduce([], fn
      kv, result when is_string_kv(kv) -> [kv | result]
      value, _ -> raise ArgumentError, "invalid key/value pairs: #{inspect(value)}"
    end)
    |> Enum.reverse()
  end
end
