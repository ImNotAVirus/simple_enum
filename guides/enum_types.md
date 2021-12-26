# Enum types

Enums automatically generate typespecs to be used with Dialyzer.

## Example

    # lib/my_app/enums.ex
    defmodule MyApp.Enums do
    import SimpleEnum, only: [defenum: 2]

      defenum :color, [:blue, :green, :red]
      defenum :state, [{:active, 1}, :inactive, {:unknown, -1}, :default]
      defenum :day, monday: "MON", tuesday: "TUE", wednesday: "WED"
    end

    iex> t(MyApp.Enums)
    @type color() :: :blue | :green | :red | 0 | 1 | 2
    @type color_keys() :: :blue | :green | :red
    @type color_values() :: 0 | 1 | 2
    @type day() :: :monday | :tuesday | :wednesday | String.t()
    @type day_keys() :: :monday | :tuesday | :wednesday
    @type day_values() :: String.t()
    @type state() :: :active | :inactive | :unknown | :default | 1 | 2 | -1 | 0
    @type state_keys() :: :active | :inactive | :unknown | :default
    @type state_values() :: 1 | 2 | -1 | 0

**NOTE**: As you can see, in the case of a string-based Enum, the type generated
for a value's typespec will be `t:String.t/0` since it is not possible to specify a
String set in typespecs.
