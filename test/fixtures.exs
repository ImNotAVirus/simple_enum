defmodule MyApp.Enums do
  import SimpleEnum, only: [defenum: 2]

  defenum :color, [:blue, :green, :red]
  defenum :state, [{:active, 1}, :inactive, {:unknown, -1}, :default]
  defenum :day, monday: "MON", tuesday: "TUE", wednesday: "WED"
end
