defmodule Timertimer.TimerManager do
  use GenServer
  require Logger
  alias Timertimer.Competition

  @tick_rate 40

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, left_pid} = Timertimer.TimerWorker.start_link(:left, self(), @tick_rate)
    {:ok, right_pid} = Timertimer.TimerWorker.start_link(:right, self(), @tick_rate)

    state = %{
      start_time: nil,
      left: %{elapsed: 0, running: false},
      right: %{elapsed: 0, running: false},
      left_pid: left_pid,
      right_pid: right_pid,
      countdown: false,
      left_athlete_id: nil,
      right_athlete_id: nil,
      left_round: nil,
      right_round: nil
    }

    {:ok, state}
  end

  def start_timer(options \\ []) do
    side = Keyword.get(options, :side, :both)
    delay_ms = Keyword.get(options, :delay_ms, 3000)
    left_athlete_id = Keyword.get(options, :left_athlete_id)
    right_athlete_id = Keyword.get(options, :right_athlete_id)
    left_round = Keyword.get(options, :left_round)
    right_round = Keyword.get(options, :right_round)

    GenServer.cast(
      __MODULE__,
      {:start_timer,
       %{
         side: side,
         delay_ms: delay_ms,
         left_athlete_id: left_athlete_id,
         right_athlete_id: right_athlete_id,
         left_round: left_round,
         right_round: right_round
       }}
    )
  end

  def stop_timer(side), do: GenServer.cast(__MODULE__, {:stop_timer, side})
  def stop_timers, do: GenServer.cast(__MODULE__, :stop_timers)
  def reset_timer, do: GenServer.cast(__MODULE__, :reset_timer)
  def reset_timer_times, do: GenServer.cast(__MODULE__, :reset_timer_times)
  def false_start, do: GenServer.cast(__MODULE__, :false_start)

  def get_state, do: GenServer.call(__MODULE__, :get_state)
  def get_running, do: GenServer.call(__MODULE__, :get_running)

  def update_athlete(side, athlete_id) do
    GenServer.cast(__MODULE__, {:update_athlete, side, athlete_id})
  end

  def update_round(side, round) do
    GenServer.cast(__MODULE__, {:update_round, side, round})
  end

  def handle_cast({:update_athlete, :left, athlete_id}, state) do
    {:noreply, %{state | left_athlete_id: athlete_id}}
  end

  def handle_cast({:update_athlete, :right, athlete_id}, state) do
    {:noreply, %{state | right_athlete_id: athlete_id}}
  end

  def handle_cast({:update_round, :left, round}, state) do
    {:noreply, %{state | left_round: round}}
  end

  def handle_cast({:update_round, :right, round}, state) do
    {:noreply, %{state | right_round: round}}
  end

  def handle_cast({:start_timer, options}, state) do
    if state.start_time == nil do
      state = %{
        state
        | left_athlete_id: options.left_athlete_id,
          right_athlete_id: options.right_athlete_id,
          left_round: options.left_round,
          right_round: options.right_round
      }

      if options.delay_ms > 0 do
        Process.send_after(self(), {:countdown, "2", options.side}, 1000)
        new_state = %{state | countdown: true}
        broadcast_countdown("3")
        {:noreply, new_state}
      else
        start_time = System.monotonic_time(:millisecond)
        new_state = start_timers(state, options.side, start_time)
        {:noreply, new_state}
      end
    else
      {:noreply, state}
    end
  end

  def handle_cast({:stop_timer, side}, state) do
    case side do
      :left ->
        exact_elapsed = GenServer.call(state.left_pid, :stop_and_get_elapsed)

        if state.left_athlete_id && state.left_round do
          save_time(state.left_athlete_id, state.left_round, exact_elapsed)
        end

        new_state = %{state | left: %{elapsed: exact_elapsed, running: false}}
        broadcast(new_state)
        {:noreply, new_state}

      :right ->
        exact_elapsed = GenServer.call(state.right_pid, :stop_and_get_elapsed)

        if state.right_athlete_id && state.right_round do
          save_time(state.right_athlete_id, state.right_round, exact_elapsed)
        end

        new_state = %{state | right: %{elapsed: exact_elapsed, running: false}}
        broadcast(new_state)
        {:noreply, new_state}
    end
  end

  def handle_cast(:stop_timers, state) do
    left_exact_elapsed = GenServer.call(state.left_pid, :stop_and_get_elapsed)
    right_exact_elapsed = GenServer.call(state.right_pid, :stop_and_get_elapsed)

    if state.left_athlete_id && state.left_round do
      save_time(state.left_athlete_id, state.left_round, left_exact_elapsed)
    end

    if state.right_athlete_id && state.right_round do
      save_time(state.right_athlete_id, state.right_round, right_exact_elapsed)
    end

    new_state = %{
      state
      | left: %{elapsed: left_exact_elapsed, running: false},
        right: %{elapsed: right_exact_elapsed, running: false}
    }

    broadcast(new_state)
    {:noreply, new_state}
  end

  def handle_cast(:reset_timer, state) do
    GenServer.cast(state.left_pid, :reset)
    GenServer.cast(state.right_pid, :reset)

    new_state = %{
      state
      | start_time: nil,
        left: %{elapsed: 0, running: false},
        right: %{elapsed: 0, running: false},
        countdown: false,
        left_athlete_id: nil,
        right_athlete_id: nil,
        left_round: nil,
        right_round: nil
    }

    broadcast({:reset_timer, new_state})
    {:noreply, new_state}
  end

  def handle_cast(:reset_timer_times, state) do
    GenServer.cast(state.left_pid, :reset)
    GenServer.cast(state.right_pid, :reset)

    new_state = %{
      state
      | start_time: nil,
        left: %{elapsed: 0, running: false},
        right: %{elapsed: 0, running: false},
        countdown: false
    }

    broadcast({:reset_timer, new_state})
    {:noreply, new_state}
  end

  def handle_cast(:false_start, state) do
    GenServer.cast(state.left_pid, :reset)
    GenServer.cast(state.right_pid, :reset)

    new_state = %{
      state
      | start_time: nil,
        left: %{elapsed: 0, running: false},
        right: %{elapsed: 0, running: false},
        countdown: false
    }

    broadcast({:false_start})
    {:noreply, new_state}
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call(:get_running, _from, state) do
    running = state.left.running || state.right.running
    {:reply, running, state}
  end

  def handle_info({:countdown, "2", side}, state) do
    broadcast_countdown("2")
    Process.send_after(self(), {:countdown, "1", side}, 1000)
    {:noreply, state}
  end

  def handle_info({:countdown, "1", side}, state) do
    broadcast_countdown("1")
    Process.send_after(self(), {:countdown, "go", side}, 1000)
    {:noreply, state}
  end

  def handle_info({:countdown, "go", side}, state) do
    broadcast_countdown("go")
    start_time = System.monotonic_time(:millisecond)
    new_state = start_timers(state, side, start_time)
    {:noreply, new_state}
  end

  def handle_info({:update, side, elapsed, running}, state) do
    new_state =
      case side do
        :left -> Map.put(state, :left, %{elapsed: elapsed, running: running})
        :right -> Map.put(state, :right, %{elapsed: elapsed, running: running})
      end

    broadcast(new_state)
    {:noreply, new_state}
  end

  defp start_timers(state, side, start_time) do
    new_state =
      state
      |> Map.put(:start_time, start_time)
      |> put_in([:left, :running], side in [:both, :left])
      |> put_in([:right, :running], side in [:both, :right])

    if side in [:both, :left] do
      GenServer.cast(state.left_pid, {:start, start_time})
    end

    if side in [:both, :right] do
      GenServer.cast(state.right_pid, {:start, start_time})
    end

    broadcast(new_state)
    new_state
  end

  defp save_time(athlete_id, round, elapsed_time) do
    time_attrs = %{
      athlete_id: athlete_id,
      round: round,
      time: elapsed_time
    }

    case Competition.create_time(time_attrs) do
      {:ok, _time} ->
        Logger.info(
          "Saved time for athlete #{athlete_id}, round: #{round}, time: #{elapsed_time}"
        )

        :ok

      {:error, changeset} ->
        Logger.error("Error saving time: #{inspect(changeset)}")
        :error
    end
  end

  defp broadcast(data) do
    Phoenix.PubSub.broadcast(Timertimer.PubSub, "timer", {:timer_update, data})
  end

  defp broadcast_countdown(message) do
    Phoenix.PubSub.broadcast(Timertimer.PubSub, "timer", {:countdown, message})
  end
end
