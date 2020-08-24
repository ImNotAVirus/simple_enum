defmodule SimpleEnum do
  @moduledoc """
  Documentation for `SimpleEnum`.
  """

  defguardp is_kv(kv) when is_tuple(kv) and tuple_size(kv) == 2 and is_atom(elem(kv, 0))
  defguardp is_integer_kv(kv) when is_kv(kv) and is_integer(elem(kv, 1))
  defguardp is_binary_kv(kv) when is_kv(kv) and is_binary(elem(kv, 1))

  @spec defenum(atom(), [atom() | tuple(), ...]) :: any()
  defmacro defenum(name, kv) do
    quote bind_quoted: [name: name, kv: kv, parent: __MODULE__] do
      fields = parent.__fields__(name, kv)
      keys = Keyword.keys(fields)
      values = Keyword.values(fields)

      # TODO: Check duplicate keys
      # TODO: Check duplicate values

      # Define new @type
      type_name = Macro.var(name, __MODULE__)
      @type unquote(type_name) :: unquote(Enum.reduce(keys, &{:|, [], [&1, &2]}))

      # Define introspection helpers
      def unquote(name)(:__keys__), do: unquote(keys)
      def unquote(name)(:__values__), do: unquote(values)
      def unquote(name)(:__fields__), do: unquote(fields)

      # Define enum
      Enum.each(fields, fn {k, v} ->
        # def name(key), do: value
        def unquote(name)(unquote(k)), do: unquote(v)
        # def name(value), do: key
        def unquote(name)(unquote(v)), do: unquote(k)

        # def name(key, :key), do: key
        def unquote(name)(unquote(k), :key), do: unquote(k)
        # def name(key, :value), do: value
        def unquote(name)(unquote(k), :value), do: unquote(v)
        # def name(key, :tuple), do: {key, value}
        def unquote(name)(unquote(k), :tuple), do: {unquote(k), unquote(v)}

        # def name(value, :key), do: key
        def unquote(name)(unquote(v), :key), do: unquote(k)
        # def name(value, :value), do: value
        def unquote(name)(unquote(v), :value), do: unquote(v)
        # def name(value, :tuple), do: {key, value}
        def unquote(name)(unquote(v), :tuple), do: {unquote(k), unquote(v)}
      end)
    end
  end

  ## Helpers

  @doc false
  @spec __fields__(atom(), nonempty_maybe_improper_list()) ::
          keyword(integer()) | keyword(binary())
  def __fields__(name, []) do
    raise ArgumentError, "cannot define enum #{inspect(name)}: it does not contain keys/values"
  end

  def __fields__(_name, [key | _] = fields) when is_atom(key) do
    prepare_integer_fields(fields)
  end

  def __fields__(_name, [kv | _] = fields) when is_integer_kv(kv) do
    prepare_integer_fields(fields)
  end

  def __fields__(_name, [kv | _] = fields) when is_binary_kv(kv) do
    prepare_binary_fields(fields)
  end

  def __fields__(name, [key | _]) do
    raise ArgumentError,
          "cannot define enum #{inspect(name)}: invalid value for enum " <>
            "field: #{inspect(key)}"
  end

  ## Private functions

  @doc false
  defp prepare_integer_fields(fields, counter \\ 0, result \\ [])
  defp prepare_integer_fields([], _counter, result), do: Enum.reverse(result)

  defp prepare_integer_fields([key | tail], counter, result) when is_atom(key) do
    prepare_integer_fields(tail, counter + 1, [{key, counter} | result])
  end

  defp prepare_integer_fields([kv | tail], _counter, result) when is_integer_kv(kv) do
    {_key, value} = kv
    prepare_integer_fields(tail, value + 1, [kv | result])
  end

  defp prepare_integer_fields([term | _tail], _counter, _result) do
    raise ArgumentError,
          "invalid field value for `#{term}`. It must be an atom or a tuple {atom(), integer()}"
  end

  @doc false
  defp prepare_binary_fields(fields, result \\ [])
  defp prepare_binary_fields([], result), do: Enum.reverse(result)

  defp prepare_binary_fields([kv | tail], result) when is_binary_kv(kv) do
    prepare_binary_fields(tail, [kv | result])
  end

  defp prepare_binary_fields([term | _tail], _result) do
    raise ArgumentError,
          "invalid field value for `#{term}`. It must be a tuple {atom(), binary()}"
  end
end
