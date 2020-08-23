defmodule SimpleEnumTest do
  use ExUnit.Case, async: true

  require SimpleEnum
  doctest SimpleEnum

  SimpleEnum.defenum(:color, [:blue, :green, :red])

  describe "defenum macros" do
    # TODO: Check new @type definition

    test "metadata" do
      assert color(:__keys__) == [:blue, :green, :red]
      assert color(:__values__) == [0, 1, 2]
      assert color(:__fields__) == [blue: 0, green: 1, red: 2]
    end

    test "enum_name/1" do
      assert color(:blue) == 0
      assert color(:green) == 1
      assert color(:red) == 2

      assert color(0) == :blue
      assert color(1) == :green
      assert color(2) == :red
    end

    test "enum_name/2" do
      assert color(:blue, :key) == :blue
      assert color(:blue, :value) == 0
      assert color(:blue, :tuple) == {:blue, 0}

      assert color(0, :key) == :blue
      assert color(0, :value) == 0
      assert color(0, :tuple) == {:blue, 0}

      assert color(:green, :key) == :green
      assert color(:green, :value) == 1
      assert color(:green, :tuple) == {:green, 1}

      assert color(1, :key) == :green
      assert color(1, :value) == 1
      assert color(1, :tuple) == {:green, 1}

      assert color(:red, :key) == :red
      assert color(:red, :value) == 2
      assert color(:red, :tuple) == {:red, 2}

      assert color(2, :key) == :red
      assert color(2, :value) == 2
      assert color(2, :tuple) == {:red, 2}
    end
  end

  SimpleEnum.defenum(:state, [{:active, 1}, :inactive, {:default, 0}])

  describe "defenum macros with default integer values" do
    test "metadata" do
      assert state(:__keys__) == [:active, :inactive, :default]
      assert state(:__values__) == [1, 2, 0]
      assert state(:__fields__) == [active: 1, inactive: 2, default: 0]
    end
  end

  SimpleEnum.defenum(:day, monday: "MON", tuesday: "TUE", wednesday: "WED")

  describe "defenum macros with default binary values" do
    test "metadata" do
      assert day(:__keys__) == [:monday, :tuesday, :wednesday]
      assert day(:__values__) == ["MON", "TUE", "WED"]
      assert day(:__fields__) == [monday: "MON", tuesday: "TUE", wednesday: "WED"]
    end
  end

  # TODO: Failing tests
  # # MUST FAIL (`done` value == `working`)
  # defenum :state {working: 1, failed: 0, :done}

  # ######################
  # defenump :color, [:blue, :green, :red, :yellow]
end
