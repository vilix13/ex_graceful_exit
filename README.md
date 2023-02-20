# GracefulExit

Repository for testing the graceful exit behavior in Elixir app

How to test localy:
1. `iex -S mix` or `mix release & _build/dev/rel/graceful_exit/bin/graceful_exit start`
2. `ps` and grab PID of `beam`
3. `kill PID` - that sends `SIGTERM` signal to the application

### ContinueWorker is a simple GenServer that emulates items processing and is based on :continue reply

Behavior on SIGTERM signal:
  - terminate callback isn't called
  - after 10 seconds (shutdown time option) exits

### AsyncWorker is simple a GenServer that emulates items processing and is based on `Process.send_after()`

Behavior on SIGTERM signal:
  - terminate callback is called
  - exits after the terminate callback finishes