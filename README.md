# GracefulExit

Repository for testing the graceful exit behavior in Elixir app

How to test localy:
1. `iex -S mix` or `mix release & _build/dev/rel/graceful_exit/bin/graceful_exit start`
2. (in another terminal window) `ps` and grab PID of `beam`
3. (in another terminal window) `kill PID` - that sends `SIGTERM` signal to the application

### ContinueWorker is a simple GenServer that emulates items processing and is based on :continue reply

Behavior on SIGTERM signal:
  - terminate callback isn't called
  - after 10 seconds (shutdown time option) exits

### AsyncWorker is simple a GenServer that emulates items processing and is based on `Process.send_after()`

Behavior on SIGTERM signal:
  - terminate callback is called
  - exits after the terminate callback finishes

### DynamicSupervisor usage

#### test exit
1. `iex -S mix`
2. `s = GracefulExit.ItemProcessingSupervisor`
3. start the first task `DynamicSupervisor.start_child(s, {GracefulExit.AsyncWorker, Enum.to_list(1..60)})`
4. start the second task `DynamicSupervisor.start_child(s, {GracefulExit.AsyncWorker, Enum.to_list(1..60)})`
6. (in another terminal window) `ps` and grab PID of `beam`
7. (in another terminal window) `kill PID` - that sends `SIGTERM` signal to the application


#### test normal finish
1. `iex -S mix`
2. `s = GracefulExit.ItemProcessingSupervisor`
3. `DynamicSupervisor.start_child(s, {GracefulExit.AsyncWorker, Enum.to_list(1..5)})`
4. wait ~5 seconds
5. `DynamicSupervisor.count_children(s)`
