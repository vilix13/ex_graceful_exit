defmodule GracefulExit.AsyncWorker do
  @moduledoc """
  AsyncWorker is a simple GenServer that emulates items processing and is based on `Process.send_after()`

  behavior on SIGTERM signal:
    - terminate callback is called
    - exits after the terminate callback finishes
  """
  use GenServer, shutdown: 10_000
  require Logger

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args, name: GracefulExit.AsyncWorker)
    :sys.statistics(pid, true)
    :sys.trace(pid, true)
    {:ok, pid}
  end

  def start_processing(items_to_process) when is_list(items_to_process) do
    GenServer.cast(GracefulExit.AsyncWorker, {:start_processing, items_to_process})
  end

  @impl GenServer
  def init(items_to_process) do
    Logger.info("[GracefulExit.AsyncWorker] started")

    Process.flag(:trap_exit, true)

    {:ok, items_to_process}
  end

  @impl GenServer
  def handle_cast({:start_processing, items_to_process}, _state) do
    rest_items = process_items(items_to_process)
    # Process.send_after(self, {:do_startprocess})

    {:noreply, rest_items}
  end

  @impl GenServer
  def handle_info(:process_items, []) do
    Logger.info("[GracefulExit.AsyncWorker] processing finished")

    {:noreply, []}
  end

  @impl GenServer
  def handle_info(:process_items, items_to_process) do
    rest_items = process_items(items_to_process)

    {:noreply, rest_items}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.warn("[GracefulExit.AsyncWorker] handle_info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.warn("[GracefulExit.AsyncWorker] terminate reason: #{inspect(reason)}")
    # emulates cleanup work
    Process.sleep(5000)
    Logger.warn("[GracefulExit.AsyncWorker] cleanup finished. \nexiting...")
  end

  def process_items(items_to_process) do
    [item | rest_items] = items_to_process
    process_item(item)
    Process.send_after(self(), :process_items, 0)

    rest_items
  end

  defp process_item(item) do
    Logger.info("[GracefulExit.AsyncWorker] Processing item #{inspect(item)} ...")
    Process.sleep(1000)
  end
end
