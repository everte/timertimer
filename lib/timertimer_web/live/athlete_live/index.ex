defmodule TimertimerWeb.AthleteLive.Index do
  use TimertimerWeb, :live_view

  alias Timertimer.Competition
  alias Timertimer.Competition.Athlete

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> allow_upload(:picture,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, stream(socket, :athletes, Competition.list_athletes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Athlete")
    |> assign(:athlete, Competition.get_athlete!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Athlete")
    |> assign(:athlete, %Athlete{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Athletes")
    |> assign(:athlete, nil)
  end

  @impl true
  def handle_info({TimertimerWeb.AthleteLive.FormComponent, {:saved, athlete}}, socket) do
    {:noreply, stream_insert(socket, :athletes, athlete)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    athlete = Competition.get_athlete!(id)
    {:ok, _} = Competition.delete_athlete(athlete)

    {:noreply, stream_delete(socket, :athletes, athlete)}
  end
end
