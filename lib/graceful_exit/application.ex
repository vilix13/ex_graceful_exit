defmodule GracefulExit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GracefulExit.ContinueWorker,
      GracefulExit.AsyncWorker
    ]

    :timer.apply_after(2000, GracefulExit.ContinueWorker, :start_processing, [Enum.to_list(1..60)])
    :timer.apply_after(2000, GracefulExit.AsyncWorker, :start_processing, [Enum.to_list(1..60)])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GracefulExit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
