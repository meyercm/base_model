defmodule BaseModelTest do
  use ExUnit.Case
  doctest BaseModel

  test "greets the world" do
    assert BaseModel.hello() == :world
  end
end
