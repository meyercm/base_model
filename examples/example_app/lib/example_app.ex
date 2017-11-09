defmodule ExampleApp do
  @moduledoc """
  Documentation for ExampleApp.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExampleApp.hello
      :world

  """
  defmacro __using__(_opts) do
    quote do
      alias ExampleApp.Models.{User, Problem}
    end
  end
end
