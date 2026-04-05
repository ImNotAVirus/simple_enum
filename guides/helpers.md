# Helpers and Guards

Each Enum defined with `defenum/2` automatically generates a set of helpers
and guards to access its data and validate membership.

## Helpers

Zero-arity macros are generated to access the Enum's keys, values, and
enumerators. They are always resolved at compile time.

    iex> defmodule MyEnums do
    ...>   import SimpleEnum, only: [defenum: 2]
    ...>
    ...>   defenum :color, [:blue, :green, :red]
    ...> end

    iex> MyEnums.color_keys()
    [:blue, :green, :red]
    iex> MyEnums.color_values()
    [0, 1, 2]
    iex> MyEnums.color_enumerators()
    [blue: 0, green: 1, red: 2]

Since they expand to literals, they can be used anywhere: guards, module
attributes, pattern matches, etc.

    iex> case 2 do
    ...>   x when x in MyEnums.color_values() -> :ok
    ...> end
    :ok

## Guards

Three guards are generated for each Enum to validate membership:

- `is_name/1` - checks if a value is a valid key **or** value
- `is_name_key/1` - checks if a value is a valid key
- `is_name_value/1` - checks if a value is a valid value

### is_name/1

    iex> MyEnums.is_color(:blue)
    true
    iex> MyEnums.is_color(0)
    true
    iex> MyEnums.is_color(:nope)
    false

### is_name_key/1

    iex> MyEnums.is_color_key(:blue)
    true
    iex> MyEnums.is_color_key(0)
    false

### is_name_value/1

    iex> MyEnums.is_color_value(0)
    true
    iex> MyEnums.is_color_value(:blue)
    false

These guards can be used in `when` clauses, `case`, and function bodies:

    iex> defmodule MyApp.Controller do
    ...>   require MyEnums
    ...>
    ...>   def handle(color) when MyEnums.is_color(color) do
    ...>     {:ok, color}
    ...>   end
    ...>
    ...>   def handle(_), do: :error
    ...> end

    iex> MyApp.Controller.handle(:blue)
    {:ok, :blue}
    iex> MyApp.Controller.handle(:nope)
    :error

## Integration with Ecto

Helpers make it easy to integrate SimpleEnum with other libraries:

    # lib/my_app/accounts/user_enums.ex
    defmodule MyApp.Accounts.UserEnums do
      import SimpleEnum, only: [defenum: 2]
      defenum :user_role, [:admin, :moderator, :seller, :buyer]
    end

    # lib/my_app/accounts/user_role.ex
    defmodule MyApp.Accounts.UserRole do
      require MyApp.Accounts.UserEnums
      alias MyApp.Accounts.UserEnums

      use EctoEnum, type: :user_role, enums: UserEnums.user_role_enumerators()
    end
