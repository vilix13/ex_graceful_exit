defmodule GracefulExit.AsyncWorker do
  @moduledoc """
  AsyncWorker is a simple GenServer that emulates items processing and is based on `Process.send_after()`

  behavior on SIGTERM signal:
    - terminate callback is called
    - exits after the terminate callback finishes
  """
  use GenServer, shutdown: 10_000, restart: :temporary
  require Logger

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args)
    :sys.statistics(pid, true)
    :sys.trace(pid, true)
    {:ok, pid}
  end

  @impl GenServer
  def init(items_to_process) do
    Logger.info("[GracefulExit.AsyncWorker] #{inspect(self())} started")

    Process.flag(:trap_exit, true)

    Process.send_after(self(), :start_processing, 0)

    {:ok, items_to_process}
  end

  @impl GenServer
  def handle_info(:start_processing, items_to_process) do
    rest_items = process_items(items_to_process)

    {:noreply, rest_items}
  end

  @impl GenServer
  def handle_info(:process_items, []) do
    Logger.info("[GracefulExit.AsyncWorker] #{inspect(self())} processing finished")

    {:stop, :normal, []}
  end

  @impl GenServer
  def handle_info(:process_items, items_to_process) do
    rest_items = process_items(items_to_process)

    {:noreply, rest_items}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.warn("[GracefulExit.AsyncWorker] #{inspect(self())} handle_info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl GenServer
  def terminate(:normal, _state) do
    Logger.warn(
      "[GracefulExit.AsyncWorker] #{inspect(self())} terminate reason: :normal\nexiting..."
    )
  end

  @impl GenServer
  def terminate(:shutdown, _state) do
    Logger.warn("[GracefulExit.AsyncWorker] #{inspect(self())} terminate reason: :shutdown")
    # emulates cleanup work
    Process.sleep(5000)
    Logger.warn("[GracefulExit.AsyncWorker] #{inspect(self())} cleanup finished. \nexiting...")
  end

  def process_items(items_to_process) do
    [item | rest_items] = items_to_process
    process_item(item)
    Process.send_after(self(), :process_items, 0)

    rest_items
  end

  defp process_item(item) do
    Logger.info(
      "[GracefulExit.AsyncWorker] #{inspect(self())} Processing item #{inspect(item)} ..."
    )

    Process.sleep(1000)
  end
end
