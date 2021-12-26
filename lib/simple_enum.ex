defmodule SimpleEnum do
  readme_path = [__DIR__, "..", "README.md"] |> Path.join() |> Path.expand()

  @external_resource readme_path
  @moduledoc readme_path
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  ## Public API

  @doc ~S"""
  Defines a set of macros to create and access Enumerations.

  The name of the generated macros and types will be `name` (which has to be an atom).  
  The `enumerators` argument has to be either:

   * A keyword list composed of strings (to create a string-based Enumeration)
   * A keyword list composed of integers (to create an integer-based Enumeration)
   * A list of atoms (to create an integer-based Enumeration)

  For more details about [string-based Enumeration](guides/string_based_enum.md) and
  [integer-based Enumeration](guides/integer_based_enum.md), you can check the
  corresponding guide.

  The following macros are generated:

   * `name/1` to access a key, a value or to inspect an Enumeration
   * `name/2` to access a key, a value or its tuple by specifying the return type

  The following types are generated:

   * `@type enum :: :key1 | :key2 | :value1 | :value2`
   * `@type enum_keys :: :key1 | :key2`
   * `@type enum_values :: :value1 | :value2`

  For more details about [types](guides/enum_types.md) you can also check the
  corresponding guide.

  All these macros are public macros (as defined by `defmacro/2`).

  See the "Examples" section for examples on how to use these macros.

  ## Examples

      defmodule MyApp.Enums do
        import SimpleEnum, only: [defenum: 2]
        defenum :color, [:blue, :green, :red]
      end

  In the example above, a set of macros named `color` but with different arities
  will be defined to manipulate the underlying Enumeration.

      # Import the module to make the color macros locally available
      import MyApp.Enums
      
      # To lookup the corresponding value
      color(:blue)    #=> 0
      color(:green)   #=> 1
      color(:red)     #=> 2
      color(0)        #=> :blue
      color(1)        #=> :green
      color(2)        #=> :red
      
      # To lookup for the key regardless of the given value
      color(:red, :key) #=> :red
      color(2, :key)    #=> :red
      
      # To lookup for the value regardless of the given value
      color(:red, :value) #=> 2
      color(2, :value)    #=> 2
      
      # To get the key/value pair of the given value
      color(:red, :tuple) #=> {:red, 2}
      color(2, :tuple)    #=> {:red, 2}

  Is also possible to inspect the Enumeration by using introspection helpers :

      color(:__keys__)        #=> [:blue, :green, :red]
      color(:__values__)      #=> [0, 1, 2]
      color(:__enumerators__) #=> [blue: 0, green: 1, red: 2]

  """
  defmacro defenum(name, enumerators) do
    expanded_name = Macro.expand(name, __CALLER__)
    expanded_kv = Macro.prewalk(enumerators, &Macro.expand(&1, __CALLER__))
    enum_name = "#{inspect(__CALLER__.module)}.#{expanded_name}"
    fields = kv_to_fields(expanded_kv, enum_name, __CALLER__)
    keys = Keyword.keys(fields)
    values = Keyword.values(fields)

    raise_if_duplicate!("key", keys, enum_name, __CALLER__)
    raise_if_duplicate!("value", values, enum_name, __CALLER__)

    quote location: :keep do
      @name unquote(expanded_name)
      @enum_name unquote(enum_name)
      @fields unquote(fields)
      @keys unquote(keys)
      @values unquote(values)
      @types [:key, :value, :tuple]

      @fields_rev @fields
                  |> Enum.map(fn {k, v} -> {v, k} end)
                  |> Enum.into(%{})
                  |> Macro.escape()

      unquote(types())
      unquote(def_fast_arity_1())
      unquote(def_fast_arity_2())

      # Maybe if would be better to use __before_compile__ to append these functions?
      if not Module.defines?(__MODULE__, {:slow_arity_1, 4}) do
        unquote(def_slow_arity_1())
        unquote(def_slow_arity_2())
      end
    end
  end

  ## Define helpers

  defp types() do
    quote unquote: false, location: :keep do
      keys_ast = @keys |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]})
      last_key = Enum.at(@keys, -1)

      # @type name_keys :: :key1 | :key2 | :key3
      @type unquote(Macro.var(:"#{@name}_keys", __MODULE__)) :: unquote(keys_ast)

      if @values |> Enum.at(0) |> is_binary() do
        # @type name_values :: String.t()
        @type unquote(Macro.var(:"#{@name}_values", __MODULE__)) :: String.t()

        string_t_ast = {{:., [], [{:__aliases__, [alias: false], [:String]}, :t]}, [], []}

        # @type name :: :key1 | :key2 | :key3 | String.t()
        @type unquote(Macro.var(@name, __MODULE__)) ::
                unquote(
                  Macro.postwalk(keys_ast, fn
                    ^last_key = x -> {:|, [], [x, string_t_ast]}
                    x -> x
                  end)
                )
      else
        values_ast = @values |> Enum.reverse() |> Enum.reduce(&{:|, [], [&1, &2]})

        # @type name_values :: 1 | 2 | 3
        @type unquote(Macro.var(:"#{@name}_values", __MODULE__)) :: unquote(values_ast)

        # @type name :: :key1 | :key2 | :key3 | 1 | 2 | 3
        @type unquote(Macro.var(@name, __MODULE__)) ::
                unquote(
                  Macro.postwalk(keys_ast, fn
                    ^last_key = x -> {:|, [], [x, values_ast]}
                    x -> x
                  end)
                )
      end
    end
  end

  defp def_fast_arity_1() do
    quote unquote: false, location: :keep do
      defmacro unquote(@name)(value) do
        case Macro.expand(value, __CALLER__) do
          ## Introspecton
          # def name(:__keys__), do: @keys
          :__keys__ -> unquote(@keys)
          # def name(:__values__), do: @values
          :__values__ -> unquote(@values)
          # def name(:__enumerators__), do: @fields
          :__enumerators__ -> unquote(@fields)
          #
          ## Fast/Compile time Access
          # def name(key), do: value
          x when x in unquote(@keys) -> Keyword.fetch!(unquote(@fields), x)
          # def name(value), do: key
          x when x in unquote(@values) -> Map.fetch!(unquote(@fields_rev), x)
          #
          ## Callback to slow access
          x -> slow_arity_1(x, @fields, @fields_rev, @enum_name)
        end
      end
    end
  end

  defp def_fast_arity_2() do
    quote unquote: false, location: :keep do
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
          x -> slow_arity_2(x, @fields, @fields_rev, @enum_name)
        end
      end
    end
  end

  defp def_slow_arity_1() do
    quote unquote: false, location: :keep, generated: true do
      defp slow_arity_1(expanded_val, fields, fields_rev, enum_name) do
        keys = Keyword.keys(fields)
        values = Keyword.values(fields)

        quote do
          value_error = """
          invalid value #{inspect(unquote(expanded_val))} for Enum #{unquote(enum_name)}/1. \
          Expected one of #{inspect(List.flatten([unquote(keys) | unquote(values)]))}
          """

          case unquote(expanded_val) do
            ## Introspecton (cf. Fast Access for more details)
            :__keys__ -> unquote(keys)
            :__values__ -> unquote(values)
            :__enumerators__ -> unquote(fields)
            ## Slow/Runtime Access (cf. Fast Access for more details)
            x when x in unquote(keys) -> Keyword.fetch!(unquote(fields), x)
            x when x in unquote(values) -> Map.fetch!(unquote(fields_rev), x)
            ## Error handling
            x -> raise ArgumentError, value_error
          end
        end
      end
    end
  end

  defp def_slow_arity_2() do
    quote unquote: false, location: :keep, generated: true do
      defp slow_arity_2({value, type} = expanded_tuple, fields, fields_rev, enum_name) do
        keys = Keyword.keys(fields)
        values = Keyword.values(fields)

        quote do
          value_error = """
          invalid value #{inspect(unquote(value))} for Enum #{unquote(enum_name)}/2. \
          Expected one of #{inspect(List.flatten([unquote(keys) | unquote(values)]))}
          """

          type_error = """
          invalid type #{inspect(unquote(type))}. Expected one of \
          #{inspect(unquote(@types))}
          """

          case unquote(expanded_tuple) do
            ## Slow/Runtime Access (cf. Fast Access for more details)
            {x, :key} when x in unquote(keys) -> x
            {x, :value} when x in unquote(values) -> x
            {x, :key} when x in unquote(values) -> Map.fetch!(unquote(fields_rev), x)
            {x, :value} when x in unquote(keys) -> Keyword.fetch!(unquote(fields), x)
            {x, :tuple} when x in unquote(keys) -> {x, Keyword.fetch!(unquote(fields), x)}
            {x, :tuple} when x in unquote(values) -> {Map.fetch!(unquote(fields_rev), x), x}
            ## Error handling
            {_, t} when t not in unquote(@types) -> raise ArgumentError, type_error
            {x, _} -> raise ArgumentError, value_error
          end
        end
      end
    end
  end

  ## Internal functions

  defguardp is_kv(kv) when is_tuple(kv) and tuple_size(kv) == 2 and is_atom(elem(kv, 0))
  defguardp is_integer_kv(kv) when is_kv(kv) and is_integer(elem(kv, 1))
  defguardp is_string_kv(kv) when is_kv(kv) and is_binary(elem(kv, 1))

  defp kv_to_fields(kv, enum_name, caller) do
    case kv do
      [k | _] when is_atom(k) ->
        int_kv_to_fields(kv, enum_name, caller)

      [ikv | _] when is_integer_kv(ikv) ->
        int_kv_to_fields(kv, enum_name, caller)

      [skv | _] when is_string_kv(skv) ->
        str_kv_to_fields(kv, enum_name, caller)

      [] ->
        raise CompileError,
          file: caller.file,
          line: caller.line,
          description: "enum #{enum_name} cannot be empty"

      x ->
        raise CompileError,
          file: caller.file,
          line: caller.line,
          description: "invalid fields for enum #{enum_name}. Got #{inspect(x)}"
    end
  end

  defp int_kv_to_fields(kv, enum_name, caller) do
    kv
    |> Enum.reduce({[], 0}, fn
      key, {result, counter} when is_atom(key) ->
        {[{key, counter} | result], counter + 1}

      {key, counter} = kv, {result, _} when is_integer_kv(kv) ->
        {[{key, counter} | result], counter + 1}

      value, _ ->
        raise CompileError,
          file: caller.file,
          line: caller.line,
          description: "invalid fields #{inspect(value)} for integer-based enum #{enum_name}"
    end)
    |> Kernel.elem(0)
    |> Enum.reverse()
  end

  defp str_kv_to_fields(kv, enum_name, caller) do
    kv
    |> Enum.reduce([], fn
      kv, result when is_string_kv(kv) ->
        [kv | result]

      value, _ ->
        raise CompileError,
          file: caller.file,
          line: caller.line,
          description: "invalid fields #{inspect(value)} for string-based enum #{enum_name}"
    end)
    |> Enum.reverse()
  end

  defp raise_if_duplicate!(type, list, enum_name, caller) do
    dups = list -- Enum.uniq(list)

    if length(dups) > 0 do
      raise CompileError,
        file: caller.file,
        line: caller.line,
        description: "duplicate #{type} #{inspect(Enum.at(dups, 0))} found in enum #{enum_name}"
    end
  end
end
