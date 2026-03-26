defmodule TimertimerWeb.Streaming.TimerLive do
  use Phoenix.LiveView
  alias Timertimer.TimerManager
  alias TimertimerWeb.TimerComponents
  import TimerComponents

  @no_athlete %{name: "", country: nil, country2: nil}

  def mount(_params, _session, socket) do
    state = TimerManager.get_state()
    socket = assign(socket, countdown_message: nil)

    socket =
      socket
      |> assign(state)
      |> load_athletes(state.left_athlete_id, state.right_athlete_id)
      |> maybe_subscribe()

    {:ok, socket}
  end

  defp load_athletes(socket, left_id, right_id) do
    socket
    |> assign(:left_athlete, get_athlete(left_id) || @no_athlete)
    |> assign(:right_athlete, get_athlete(right_id) || @no_athlete)
  end

  defp get_athlete(nil), do: nil

  defp get_athlete(id) do
    Timertimer.Competition.get_athlete!(id)
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

  def handle_info({:round_update, %{side: :left, round: round}}, socket) do
    {:noreply, assign(socket, left_round: round)}
  end

  def handle_info({:round_update, %{side: :right, round: round}}, socket) do
    {:noreply, assign(socket, right_round: round)}
  end

  def handle_info({:countdown, "3"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "show"})
    {:noreply, socket}
  end

  def handle_info({:countdown, "2"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "2"})
    {:noreply, socket}
  end

  def handle_info({:countdown, "1"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "1"})
    {:noreply, socket}
  end

  def handle_info({:countdown, "go"}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "go"})
    {:noreply, socket}
  end

  def handle_info({:timer_update, {:false_start}}, socket) do
    socket = push_event(socket, "countdown_event", %{message: "false_start"})
    {:noreply, socket}
  end

  def handle_info({:timer_update, {:reset_timer, state}}, socket) do
    socket =
      socket
      |> assign(state)
      |> maybe_reload_athletes(
        state.left_athlete_id != socket.assigns.left_athlete_id,
        state.right_athlete_id != socket.assigns.right_athlete_id
      )

    {:noreply, socket}
  end

  def handle_info({:timer_update, state}, socket) do
    socket =
      socket
      |> assign(state)
      |> maybe_reload_athletes(
        state.left_athlete_id != socket.assigns.left_athlete_id,
        state.right_athlete_id != socket.assigns.right_athlete_id
      )

    {:noreply, socket}
  end

  defp maybe_reload_athletes(socket, false, false), do: socket

  defp maybe_reload_athletes(socket, left_changed, right_changed) do
    socket
    |> assign_new_athlete(:left_athlete, socket.assigns.left_athlete_id, left_changed)
    |> assign_new_athlete(:right_athlete, socket.assigns.right_athlete_id, right_changed)
  end

  defp assign_new_athlete(socket, _key, nil, _), do: socket
  defp assign_new_athlete(socket, _key, _id, false), do: socket

  defp assign_new_athlete(socket, key, id, true),
    do: assign(socket, key, get_athlete(id) || @no_athlete)

  defp maybe_subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Timertimer.PubSub, "timer")
    end

    socket
  end
end
