defmodule TimertimerWeb.TimeLive.Index do
  alias TimertimerWeb.ViewHelpers
  use TimertimerWeb, :live_view

  alias Timertimer.Competition
  alias Timertimer.Competition.Time
  import ViewHelpers

  @impl true
  def mount(_params, _session, socket) do
    times = Competition.list_times()
    {:ok, stream(socket, :times, times)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:ok, {times, meta}} = Competition.list_times_flop(params)
    socket = socket |> assign(:meta, meta) |> stream(:times, times, reset: true)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Time")
    |> assign(:time, Competition.get_time!(id))
    |> assign(:athletes, Competition.list_athletes())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Time")
    |> assign(:time, %Time{})
    |> assign(:athletes, Competition.list_athletes())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Times")
    |> assign(:time, nil)
  end

  @impl true
  def handle_info({TimertimerWeb.TimeLive.FormComponent, {:saved, time}}, socket) do
    {:noreply, stream_insert(socket, :times, time)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    time = Competition.get_time!(id)
    {:ok, _} = Competition.delete_time(time)

    {:noreply, stream_delete(socket, :times, time)}
  end

  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/admin/times?#{params}")}
  end
end
