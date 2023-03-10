defmodule GracefulExit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {GracefulExit.ContinueWorker, Enum.to_list(1..60)},
      # {GracefulExit.AsyncWorker, Enum.to_list(1..60)}
      {DynamicSupervisor, strategy: :one_for_one, name: GracefulExit.ItemProcessingSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GracefulExit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
