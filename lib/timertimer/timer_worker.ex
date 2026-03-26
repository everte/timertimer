defmodule Timertimer.TimerWorker do
  use GenServer
  require Logger

  def start_link(side, manager, tick_interval) do
    GenServer.start_link(__MODULE__, %{
      side: side,
      manager: manager,
      tick_interval: tick_interval,
      start_time: nil,
      elapsed: 0,
      running: false
    })
  end

  def init(state), do: {:ok, state}

  # Start timer: set start_time, mark running, and schedule ticks.
  def handle_cast({:start, start_time}, state) do
    new_state = %{state | start_time: start_time, running: true}
    schedule_tick(state.tick_interval)
    {:noreply, new_state}
  end

  def handle_cast(:stop, state) do
    current = System.monotonic_time(:millisecond)

    elapsed =
      if state.running && state.start_time, do: current - state.start_time, else: state.elapsed

    new_state = %{state | running: false, elapsed: elapsed}
    send(state.manager, {:update, state.side, elapsed, false})
    {:noreply, new_state}
  end

  def handle_cast(:reset, state) do
    {:noreply, %{state | start_time: nil, elapsed: 0, running: false}}
  end

  def handle_call(:stop_and_get_elapsed, _from, state) do
    if state.running && state.start_time do
      current = System.monotonic_time(:millisecond)
      exact_elapsed = current - state.start_time

      new_state = %{state | running: false, elapsed: exact_elapsed}

      send(state.manager, {:update, state.side, exact_elapsed, false})

      {:reply, exact_elapsed, new_state}
    else
      {:reply, state.elapsed, state}
    end
  end

  def handle_info(:tick, state) do
    if state.running do
      current = System.monotonic_time(:millisecond)
      elapsed = current - state.start_time
      send(state.manager, {:update, state.side, elapsed, true})
      schedule_tick(state.tick_interval)
    end

    {:noreply, state}
  end

  defp schedule_tick(interval) do
    Process.send_after(self(), :tick, interval)
  end
end
