defmodule GracefulExitTest do
  use ExUnit.Case
  doctest GracefulExit

  test "greets the world" do
    assert GracefulExit.hello() == :world
  end
end
