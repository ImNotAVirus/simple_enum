Code.require_file("fixtures.exs", __DIR__)

defmodule SimpleEnumTest do
  use ExUnit.Case, async: true

  require SimpleEnum
  doctest SimpleEnum

  require MyApp.Enums

  describe "defenum/2" do
    test "do not compile when key/value pair is empty" do
      code = """
      defmodule EmptyEnum do
        import SimpleEnum, only: [defenum: 2]

        defenum :test, []
      end
      """

      assert_raise CompileError,
                   "nofile:4: enum EmptyEnum.test cannot be empty",
                   fn ->
                     Code.compile_string(code)
                   end
    end
  end

  describe "metadata helpers" do
    test "with compile time access (fast)" do
      assert MyApp.Enums.color(:__keys__) == [:blue, :green, :red]
      assert MyApp.Enums.color(:__values__) == [0, 1, 2]
      assert MyApp.Enums.color(:__fields__) == [blue: 0, green: 1, red: 2]
    end

    test "with runtime access (slow)" do
      type1 = :__keys__
      assert MyApp.Enums.color(type1) == [:blue, :green, :red]
      type2 = :__values__
      assert MyApp.Enums.color(type2) == [0, 1, 2]
      type3 = :__fields__
      assert MyApp.Enums.color(type3) == [blue: 0, green: 1, red: 2]
    end

    test "for default integer values" do
      assert MyApp.Enums.state(:__keys__) == [:active, :inactive, :unknown, :default]
      assert MyApp.Enums.state(:__values__) == [1, 2, -1, 0]
      assert MyApp.Enums.state(:__fields__) == [active: 1, inactive: 2, unknown: -1, default: 0]
    end

    test "for default string values" do
      assert MyApp.Enums.day(:__keys__) == [:monday, :tuesday, :wednesday]
      assert MyApp.Enums.day(:__values__) == ["MON", "TUE", "WED"]
      assert MyApp.Enums.day(:__fields__) == [monday: "MON", tuesday: "TUE", wednesday: "WED"]
    end

    test "can be used in guards" do
      got =
        case 2 do
          x when x in MyApp.Enums.color(:__values__) -> :ok
        end

      assert got == :ok
    end
  end

  describe "enum/1" do
    test "with compile time access (fast)" do
      assert MyApp.Enums.color(:blue) == 0
      assert MyApp.Enums.color(:green) == 1
      assert MyApp.Enums.color(:red) == 2

      assert MyApp.Enums.color(0) == :blue
      assert MyApp.Enums.color(1) == :green
      assert MyApp.Enums.color(2) == :red
    end

    test "with runtime access (slow)" do
      key1 = :blue
      assert MyApp.Enums.color(key1) == 0
      key2 = :green
      assert MyApp.Enums.color(key2) == 1
      key3 = :red
      assert MyApp.Enums.color(key3) == 2

      value1 = 0
      assert MyApp.Enums.color(value1) == :blue
      value2 = 1
      assert MyApp.Enums.color(value2) == :green
      value3 = 2
      assert MyApp.Enums.color(value3) == :red
    end

    test "can be used in guards" do
      got =
        case 2 do
          x when x == MyApp.Enums.color(:red) -> :ok
        end

      assert got == :ok
    end

    @color_key :red
    test "can be used with module attributes" do
      got =
        case 2 do
          x when x == MyApp.Enums.color(@color_key) -> :ok
        end

      assert got == :ok
    end

    test "raises if invalid value" do
      assert_raise ArgumentError, ~r"^invalid value :invalid for Enum MyApp.Enums.color/1", fn ->
        MyApp.Enums.color(:invalid)
      end
    end
  end

  describe "enum/2" do
    test "with compile time access (fast)" do
      assert MyApp.Enums.color(:blue, :key) == :blue
      assert MyApp.Enums.color(:blue, :value) == 0
      assert MyApp.Enums.color(:blue, :tuple) == {:blue, 0}

      assert MyApp.Enums.color(0, :key) == :blue
      assert MyApp.Enums.color(0, :value) == 0
      assert MyApp.Enums.color(0, :tuple) == {:blue, 0}

      assert MyApp.Enums.color(:green, :key) == :green
      assert MyApp.Enums.color(:green, :value) == 1
      assert MyApp.Enums.color(:green, :tuple) == {:green, 1}

      assert MyApp.Enums.color(1, :key) == :green
      assert MyApp.Enums.color(1, :value) == 1
      assert MyApp.Enums.color(1, :tuple) == {:green, 1}

      assert MyApp.Enums.color(:red, :key) == :red
      assert MyApp.Enums.color(:red, :value) == 2
      assert MyApp.Enums.color(:red, :tuple) == {:red, 2}

      assert MyApp.Enums.color(2, :key) == :red
      assert MyApp.Enums.color(2, :value) == 2
      assert MyApp.Enums.color(2, :tuple) == {:red, 2}
    end

    test "with runtime access (slow)" do
      key = :blue
      assert MyApp.Enums.color(key, :key) == :blue
      assert MyApp.Enums.color(key, :value) == 0
      assert MyApp.Enums.color(key, :tuple) == {:blue, 0}

      value = 0
      assert MyApp.Enums.color(value, :key) == :blue
      assert MyApp.Enums.color(value, :value) == 0
      assert MyApp.Enums.color(value, :tuple) == {:blue, 0}
    end

    test "can be used in guards" do
      got =
        case {:red, 2} do
          x when x == MyApp.Enums.color(:red, :tuple) -> :ok
        end

      assert got == :ok
    end

    @color_key :red
    @enum_type :tuple
    test "can be used with module attributes" do
      got =
        case {:red, 2} do
          x when x == MyApp.Enums.color(@color_key, @enum_type) -> :ok
        end

      assert got == :ok
    end

    test "raises if invalid value" do
      assert_raise ArgumentError, ~r"^invalid value :invalid for Enum MyApp.Enums.color/2", fn ->
        MyApp.Enums.color(:invalid, :key)
      end

      assert_raise ArgumentError, ~r"^invalid type :keyys. Expected one of", fn ->
        MyApp.Enums.color(:blue, :keyys)
      end
    end
  end
end
