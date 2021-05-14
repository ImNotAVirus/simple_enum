Code.require_file("fixtures.exs", __DIR__)

defmodule SimpleEnumTest do
  use ExUnit.Case, async: true

  require SimpleEnum
  doctest SimpleEnum

  require MyApp.Enums

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
  end

  describe "enum/2" do
  end
end
