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
      @types [:key, :value, :tuple]
      @kv unquote(kv)
      @fields unquote(kv_to_fields())
      @keys Keyword.keys(@fields)
      @values Keyword.values(@fields)

      unquote(raise_if_duplicate_key!())
      unquote(raise_if_duplicate_value!())

      @fields_rev @fields
                  |> Enum.map(fn {k, v} -> {v, k} end)
                  |> Enum.into(%{})
                  |> Macro.escape()

      # TODO: Check duplicate keys/values (with `@unique true` attribute)
      # -> ValueError: duplicate values found in <enum 'Mistake'>: FOUR -> THREE
      # TODO: defenump

      unquote(types())
      unquote(def_fast_arity_1())
      unquote(def_slow_arity_1())
      unquote(def_fast_arity_2())
      unquote(def_slow_arity_2())
    end
  end

  ## Helpers

  defp kv_to_fields() do
    quote unquote: false, location: :keep do
      case @kv do
        [k | _] when is_atom(k) -> int_kv_to_fields(@kv)
        [kv | _] when is_integer_kv(kv) -> int_kv_to_fields(@kv)
        [kv | _] when is_string_kv(kv) -> str_kv_to_fields(@kv)
        [] -> raise CompileError, "enum #{@enum_name} cannot be empty"
        _ -> raise CompileError, "invalid key/value pairs for enum #{@enum_name}"
      end
    end
  end

  defp raise_if_duplicate_key!() do
    quote unquote: false do
      dups = @keys -- Enum.uniq(@keys)

      if length(dups) > 0 do
        raise CompileError, "duplicate key found (#{Enum.at(dups, 0)}) for #{@enum_name}"
      end
    end
  end

  defp raise_if_duplicate_value!() do
    quote unquote: false do
      dups = @values -- Enum.uniq(@values)

      if length(dups) > 0 do
        raise CompileError, "duplicate value found (#{Enum.at(dups, 0)}) for #{@enum_name}"
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

  defp def_fast_arity_1() do
    quote unquote: false, location: :keep, generated: true do
      defmacro unquote(@name)(value) do
        case Macro.expand(value, __CALLER__) do
          ## Introspecton
          # def name(:__keys__), do: @keys
          :__keys__ -> unquote(@keys)
          # def name(:__values__), do: @values
          :__values__ -> unquote(@values)
          # def name(:__fields__), do: @fields
          :__fields__ -> unquote(@fields)
          #
          ## Fast/Compile time Access
          # def name(key), do: value
          x when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
          # def name(value), do: key
          x when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
          #
          ## Callback to slow access
          x -> slow_arity_1(x)
        end
      end
    end
  end

  defp def_slow_arity_1() do
    quote unquote: false, location: :keep, generated: true do
      defp slow_arity_1(expanded_val) do
        value_error = """
        invalid value #{inspect(expanded_val)} for Enum #{@enum_name}/1. \
        Expected one of #{inspect(List.flatten([@keys | @values]))}
        """

        quote do
          case unquote(expanded_val) do
            ## Introspecton (cf. Fast Access for more details)
            :__keys__ -> unquote(@keys)
            :__values__ -> unquote(@values)
            :__fields__ -> unquote(@fields)
            ## Slow/Runtime Access (cf. Fast Access for more details)
            x when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
            x when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
            ## Error hadling
            x -> raise ArgumentError, unquote(value_error)
          end
        end
      end
    end
  end

  defp def_fast_arity_2() do
    quote unquote: false, location: :keep, generated: true do
      defmacro unquote(@name)(value, type) do
        expanded_val = Macro.expand(value, __CALLER__)
        expanded_type = Macro.expand(type, __CALLER__)

        case {expanded_val, expanded_type} do
          ## Fast/Compile time Access
          # def name(key, :key), do: key
          {x, :key} when x in unquote(@keys) -> x
          # def name(value, :value), do: value
          {x, :value} when x in unquote(@values) -> x
          # def name(value, :key), do: key
          {x, :key} when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
          # def name(key, :value), do: value
          {x, :value} when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
          # def name(key, :tuple), do: {key, value}
          {x, :tuple} when x in unquote(@keys) -> {x, Keyword.fetch!(unquote(@fields), x)}
          # def name(value, :tuple), do: {key, value}
          {x, :tuple} when x in unquote(@values) -> {Map.fetch!(unquote(@fields_rev), x), x}
          #
          ## Callback to slow access
          x -> slow_arity_2(x)
        end
      end

      defp slow_arity_2({value, type} = expanded_tuple) do
        value_error = """
        invalid value #{inspect(value)} for Enum #{@enum_name}/2. \
        Expected one of #{inspect(List.flatten([@keys | @values]))}
        """

        type_error = "invalid type #{inspect(type)}. Expected one of #{inspect(@types)}"

        quote do
          case unquote(expanded_tuple) do
            {x, :key} when x in unquote(@keys) -> x
            {x, :value} when x in unquote(@values) -> x
            {x, :key} when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
            {x, :value} when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
            {x, :tuple} when x in unquote(@keys) -> {x, Keyword.fetch!(unquote(@fields), x)}
            {x, :tuple} when x in unquote(@values) -> {Map.fetch!(unquote(@fields_rev), x), x}
            {_, t} when t not in unquote(@types) -> raise ArgumentError, unquote(type_error)
            {x, _} -> raise ArgumentError, unquote(value_error)
          end
        end
      end
    end
  end

  defp def_slow_arity_2() do
    quote unquote: false, location: :keep, generated: true do
      defp slow_arity_2({value, type} = expanded_tuple) do
        value_error = """
        invalid value #{inspect(value)} for Enum #{@enum_name}/2. \
        Expected one of #{inspect(List.flatten([@keys | @values]))}
        """

        type_error = "invalid type #{inspect(type)}. Expected one of #{inspect(@types)}"

        quote do
          case unquote(expanded_tuple) do
            ## Slow/Runtime Access (cf. Fast Access for more details)
            {x, :key} when x in unquote(@keys) -> x
            {x, :value} when x in unquote(@values) -> x
            {x, :key} when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
            {x, :value} when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
            {x, :tuple} when x in unquote(@keys) -> {x, Keyword.fetch!(unquote(@fields), x)}
            {x, :tuple} when x in unquote(@values) -> {Map.fetch!(unquote(@fields_rev), x), x}
            ## Error hadling
            {_, t} when t not in unquote(@types) -> raise ArgumentError, unquote(type_error)
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
