defmodule TimertimerWeb.AdminLive do
  use Phoenix.LiveView

  alias TimertimerWeb.TimerComponents
  alias Timertimer.TimerManager
  alias Timertimer.Competition
  import TimerComponents
  require Logger

  @no_athlete %{name: "------", country: nil, country2: nil}

  @impl true
  def mount(_params, _session, socket) do
    timer_state = TimerManager.get_state()
    athletes = Competition.list_athletes()

    rounds = [
      {"Test", :test},
      {"Training", :training},
      {"Qualification", :qualification},
      {"Quarter Final", :quarter},
      {"Semi Final", :half},
      {"Small Final", :small_final},
      {"Final", :final}
    ]

    left_athlete_id = Map.get(timer_state, :left_athlete_id)
    right_athlete_id = Map.get(timer_state, :right_athlete_id)
    left_round = Map.get(timer_state, :left_round)
    right_round = Map.get(timer_state, :right_round)

    socket =
      socket
      |> assign(countdown_message: nil)
      |> assign(
        start_time: timer_state.start_time,
        left: timer_state.left,
        right: timer_state.right,
        left_pid: timer_state.left_pid,
        right_pid: timer_state.right_pid,
        countdown: timer_state.countdown,
        athletes: athletes,
        rounds: rounds,
        left_athlete_id: left_athlete_id,
        right_athlete_id: right_athlete_id,
        left_round: left_round,
        right_round: right_round,
        left_athlete: find_athlete(athletes, left_athlete_id) || @no_athlete,
        right_athlete: find_athlete(athletes, right_athlete_id) || @no_athlete
      )
      |> maybe_subscribe()

    {:ok, socket}
  end

  defp find_athlete(_athletes, nil), do: @no_athlete

  defp find_athlete(athletes, athlete_id) do
    Enum.find(athletes, &(&1.id == athlete_id))
  end

  def handle_info(
        {:athlete_update, %{side: :left, athlete_id: athlete_id, athlete: athlete}},
        socket
      ) do
    {:noreply,
     assign(socket,
       left_athlete_id: athlete_id,
       left_athlete: athlete || @no_athlete
     )}
  end

  def handle_info(
        {:athlete_update, %{side: :right, athlete_id: athlete_id, athlete: athlete}},
        socket
      ) do
    {:noreply,
     assign(socket, right_athlete_id: athlete_id, right_athlete: athlete || @no_athlete)}
  end

  @impl Phoenix.LiveView
  def handle_info(message, socket) do
    do_handle_info(message, socket)
  end

  defp do_handle_info({:timer_update, {:countdown, message}}, socket) do
    {:noreply, assign(socket, countdown_message: message)}
  end

  defp do_handle_info({:timer_update, {:reset_timer, timer_state}}, socket) do
    new_assigns = %{
      start_time: timer_state.start_time,
      left: timer_state.left,
      right: timer_state.right,
      left_pid: timer_state.left_pid,
      right_pid: timer_state.right_pid,
      countdown: timer_state.countdown,
      left_athlete_id: timer_state.left_athlete_id,
      right_athlete_id: timer_state.right_athlete_id,
      left_round: timer_state.left_round,
      right_round: timer_state.right_round,
      left_athlete: find_athlete(socket.assigns.athletes, timer_state.left_athlete_id),
      right_athlete: find_athlete(socket.assigns.athletes, timer_state.right_athlete_id)
    }

    {:noreply, assign(socket, new_assigns)}
  end

  defp do_handle_info({:timer_update, {:false_start}}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "false_start"})
    {:noreply, socket}
  end

  defp do_handle_info({:timer_update, timer_state}, socket) do
    new_assigns = %{
      start_time: timer_state.start_time,
      left: timer_state.left,
      right: timer_state.right,
      left_pid: timer_state.left_pid,
      right_pid: timer_state.right_pid,
      countdown: timer_state.countdown
    }

    # Only update athlete info if it's in the timer_state
    new_assigns =
      if Map.has_key?(timer_state, :left_athlete_id) do
        Map.merge(new_assigns, %{
          left_athlete_id: timer_state.left_athlete_id,
          right_athlete_id: timer_state.right_athlete_id,
          left_round: timer_state.left_round,
          right_round: timer_state.right_round,
          left_athlete: find_athlete(socket.assigns.athletes, timer_state.left_athlete_id),
          right_athlete: find_athlete(socket.assigns.athletes, timer_state.right_athlete_id)
        })
      else
        new_assigns
      end

    {:noreply, assign(socket, new_assigns)}
  end

  defp do_handle_info({:countdown, "3"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "show"})
    {:noreply, socket}
  end

  defp do_handle_info({:countdown, "2"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "2"})
    {:noreply, socket}
  end

  defp do_handle_info({:countdown, "1"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "1"})
    {:noreply, socket}
  end

  defp do_handle_info({:countdown, "go"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "go"})
    {:noreply, socket}
  end

  defp do_handle_info(msg, socket) do
    Logger.warning("Unhandled info message: #{inspect(msg)}")
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event(event, params, socket) do
    do_handle_event(event, params, socket)
  end

  defp do_handle_event("select_left_athlete", %{"athlete_id" => ""}, socket) do
    broadcast_athlete_update(:left, nil, nil)
    {:noreply, assign(socket, left_athlete_id: nil, left_athlete: @no_athlete)}
  end

  defp do_handle_event("select_left_athlete", %{"athlete_id" => athlete_id}, socket) do
    athlete_id = String.to_integer(athlete_id)
    athlete = Enum.find(socket.assigns.athletes, &(&1.id == athlete_id))

    Logger.info("Setting left athlete to: #{athlete.name} (ID: #{athlete_id})")
    broadcast_athlete_update(:left, athlete_id, athlete)
    {:noreply, assign(socket, left_athlete_id: athlete_id, left_athlete: athlete)}
  end

  defp do_handle_event("select_right_athlete", %{"athlete_id" => ""}, socket) do
    broadcast_athlete_update(:right, nil, nil)
    {:noreply, assign(socket, right_athlete_id: nil, right_athlete: @no_athlete)}
  end

  defp do_handle_event("select_right_athlete", %{"athlete_id" => athlete_id}, socket) do
    athlete_id = String.to_integer(athlete_id)
    athlete = Enum.find(socket.assigns.athletes, &(&1.id == athlete_id))

    Logger.info("Setting right athlete to: #{athlete.name} (ID: #{athlete_id})")
    broadcast_athlete_update(:right, athlete_id, athlete)
    {:noreply, assign(socket, right_athlete_id: athlete_id, right_athlete: athlete)}
  end

  defp do_handle_event("select_left_round", %{"round" => ""}, socket) do
    broadcast_round_update(:left, "")
    {:noreply, assign(socket, left_round: nil)}
  end

  defp do_handle_event("select_left_round", %{"round" => round}, socket) do
    round = String.to_existing_atom(round)
    Logger.info("Setting left round to: #{round}")
    broadcast_round_update(:left, round)
    {:noreply, assign(socket, left_round: round)}
  end

  defp do_handle_event("select_right_round", %{"round" => ""}, socket) do
    broadcast_round_update(:right, "")
    {:noreply, assign(socket, right_round: nil)}
  end

  defp do_handle_event("select_right_round", %{"round" => round}, socket) do
    round = String.to_existing_atom(round)
    Logger.info("Setting right round to: #{round}")
    broadcast_round_update(:right, round)
    {:noreply, assign(socket, right_round: round)}
  end

  defp do_handle_event("start_timer_left", _params, socket) do
    options = [
      side: :left,
      left_athlete_id: socket.assigns.left_athlete_id,
      right_athlete_id: socket.assigns.right_athlete_id,
      left_round: socket.assigns.left_round,
      right_round: socket.assigns.right_round
    ]

    Logger.info("Starting left timer with options: #{inspect(options)}")
    TimerManager.start_timer(options)
    {:noreply, socket}
  end

  defp do_handle_event("start_timer_right", _params, socket) do
    options = [
      side: :right,
      left_athlete_id: socket.assigns.left_athlete_id,
      right_athlete_id: socket.assigns.right_athlete_id,
      left_round: socket.assigns.left_round,
      right_round: socket.assigns.right_round
    ]

    Logger.info("Starting right timer with options: #{inspect(options)}")
    TimerManager.start_timer(options)
    {:noreply, socket}
  end

  defp do_handle_event("start_timer", _params, socket) do
    options = [
      side: :both,
      left_athlete_id: socket.assigns.left_athlete_id,
      right_athlete_id: socket.assigns.right_athlete_id,
      left_round: socket.assigns.left_round,
      right_round: socket.assigns.right_round
    ]

    Logger.info("Starting both timers with options: #{inspect(options)}")
    TimerManager.start_timer(options)
    {:noreply, socket}
  end

  defp do_handle_event("stop_timer_left", _params, socket) do
    TimerManager.stop_timer(:left)
    {:noreply, socket}
  end

  defp do_handle_event("stop_timer_right", _params, socket) do
    TimerManager.stop_timer(:right)
    {:noreply, socket}
  end

  defp do_handle_event("reset_timer", _params, socket) do
    TimerManager.reset_timer()

    {:noreply, socket}
  end

  defp do_handle_event("reset_timer_times", _params, socket) do
    Logger.info("Resetting timer times only")
    TimerManager.reset_timer_times()

    {:noreply, socket}
  end

  defp do_handle_event("false_start", _params, socket) do
    TimerManager.false_start()
    {:noreply, socket}
  end

  defp do_handle_event("controller_found", %{"index" => index, "name" => name}, socket) do
    index = if is_binary(index), do: String.to_integer(index), else: index
    IO.puts("Controller found: #{name} (#{index})")
    {:noreply, socket}
  end

  defp do_handle_event(
         "button_press",
         %{"controllerIndex" => _index, "name" => "P1_RED", "pressed" => _pressed},
         socket
       ) do
    IO.puts("RED Button press on LEFT controller")
    TimerManager.stop_timer(:left)
    {:noreply, socket}
  end

  defp do_handle_event(
         "button_press",
         %{"controllerIndex" => _index, "name" => "P2_RED", "pressed" => _pressed},
         socket
       ) do
    IO.puts("RED Button press on RIGHT controller")
    TimerManager.stop_timer(:right)
    {:noreply, socket}
  end

  defp do_handle_event(
         "button_press",
         %{
           "controllerIndex" => index,
           "name" => button_name,
           "pressed" => _pressed,
           "time" => _time,
           "value" => _value
         },
         socket
       ) do
    IO.puts("Button press: #{button_name} on controller #{index}")
    {:noreply, socket}
  end

  defp do_handle_event(event, params, socket) do
    Logger.warning("Unhandled event: #{event} | params: #{inspect(params)}")
    {:noreply, socket}
  end

  defp broadcast_athlete_update(side, athlete_id, athlete) do
    Phoenix.PubSub.broadcast(
      Timertimer.PubSub,
      "timer",
      {:athlete_update, %{side: side, athlete_id: athlete_id, athlete: athlete}}
    )

    TimerManager.update_athlete(side, athlete_id)
  end

  defp broadcast_round_update(side, round) do
    Phoenix.PubSub.broadcast(
      Timertimer.PubSub,
      "timer",
      {:round_update, %{side: side, round: round}}
    )

    TimerManager.update_round(side, round)
  end

  defp maybe_subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Timertimer.PubSub, "timer")
    end

    socket
  end

  def athlete_has_name?(athlete) do
    athlete && athlete.name && String.trim(to_string(athlete.name)) != ""
  end
end
