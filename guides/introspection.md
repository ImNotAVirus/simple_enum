# Introspection

The created Enums will also have introspection helpers in order
to inspect them at compile time or at runtime.

## Examples

    iex> MyEnums.color(:__keys__)
    [:blue, :green, :red]
    iex> MyEnums.color(:__values__)
    [0, 1, 2]
    iex> MyEnums.color(:__enumerators__)
    [blue: 0, green: 1, red: 2]

Being macros, introspection helpers can be used in guards as
well as to connect SimpleEnum to other libraries/frameworks.

## Example with guards

    iex> defmodule MyEnums do
    ...>   import SimpleEnum, only: [defenum: 2]
    ...>
    ...>   defenum :color, [:blue, :green, :red]
    ...> 
    ...>   defguard is_color(value) when value in color(:__keys__) or value in color(:__values__)
    ...>   defguard is_color_key(value) when value in color(:__keys__)
    ...>   defguard is_color_value(value) when value in color(:__values__)
    ...> end
    
    iex> MyEnums.is_color(0)
    true
    iex> MyEnums.is_color(:red)
    true
    iex> MyEnums.is_color(:human) 
    false
    iex> MyEnums.is_color_key(0)
    false
    iex> MyEnums.is_color_key(:red)
    true
    iex> MyEnums.is_color_value(0)
    true
    iex> MyEnums.is_color_value(:red)
    false

## Example with Ecto

    # lib/my_app/accounts/user_enums.ex
    defmodule MyApp.Accounts.UserEnums do
      import SimpleEnum, only: [defenum: 2]
      defenum :user_role, [:admin, :moderator, :seller, :buyer]
    end

    # lib/my_app/accounts/user_role.ex
    defmodule MyApp.Accounts.UserRole do
      require MyApp.Accounts.UserEnums
      alias MyApp.Accounts.UserEnums

      use EctoEnum, type: :user_role, enums: UserEnums.user_role(:__enumerators__)
    end
