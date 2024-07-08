defmodule HTTPSpecTest do
  use ExUnit.Case
  doctest HTTPSpec

  test "greets the world" do
    assert HTTPSpec.hello() == :world
  end
end
