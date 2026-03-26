defmodule TimertimerWeb.AthleteLive.Show do
  use TimertimerWeb, :live_view

  alias Timertimer.Competition

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:athlete, Competition.get_athlete!(id))}
  end

  defp page_title(:show), do: "Show Athlete"
  defp page_title(:edit), do: "Edit Athlete"
end
