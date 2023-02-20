defmodule GracefulExit.ContinueWorker do
  @moduledoc """
  ContinueWorker is a simple GenServer that emulates items processing and is based on :continue reply

  behavior on SIGTERM signal:
    - terminate callback isn't called
    - after 10 seconds (shutdown time option) exits
  """
  use GenServer, shutdown: 10_000
  require Logger

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args, name: GracefulExit.ContinueWorker)
    :sys.statistics(pid, true)
    :sys.trace(pid, true)
    {:ok, pid}
  end

  def start_processing(items_to_process) when is_list(items_to_process) do
    GenServer.cast(GracefulExit.ContinueWorker, {:start_processing, items_to_process})
  end

  @impl GenServer
  def init(items_to_process) do
    Logger.info("[GracefulExit.ContinueWorker] started")

    Process.flag(:trap_exit, true)

    {:ok, items_to_process}
  end

  @impl GenServer
  def handle_cast({:start_processing, items_to_process}, _state) do
    {:noreply, items_to_process, {:continue, :process}}
  end

  @impl GenServer
  def handle_continue(:process, []) do
    Logger.info("[GracefulExit.ContinueWorker] processing finished")

    {:noreply, []}
  end

  @impl GenServer
  def handle_continue(:process, items_to_process) do
    [item | rest_items] = items_to_process
    process_item(item)

    {:noreply, rest_items, {:continue, :process}}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.warn("[GracefulExit.ContinueWorker] handle_info #{inspect(msg)}")
    {:noreply, state}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.warn("[GracefulExit.ContinueWorker] terminate reason: #{inspect(reason)}")
  end

  defp process_item(item) do
    Logger.info("[GracefulExit.ContinueWorker] Processing item #{inspect(item)} ...")
    Process.sleep(1000)
  end
end
