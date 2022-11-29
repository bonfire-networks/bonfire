defmodule Bonfire.AppTest do
  use ExUnit.Case
  doctest Bonfire.Application

  test "greets the world" do
    assert Bonfire.Application.hello() == :world
  end
end
