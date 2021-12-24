defmodule MyApp.Enums do
  import SimpleEnum, only: [defenum: 2]

  defenum :color, ~w(blue green red)a
  defenum :state, [{:active, 1}, :inactive, {:unknown, -1}, :default]
  defenum :day, monday: "MON", tuesday: "TUE", wednesday: "WED"
end
