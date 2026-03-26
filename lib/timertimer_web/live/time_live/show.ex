defmodule TimertimerWeb.TimeLive.Show do
  alias TimertimerWeb.ViewHelpers
  use TimertimerWeb, :live_view
  import ViewHelpers
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
     |> assign(:athletes, Competition.list_athletes())
     |> assign(:time, Competition.get_time!(id))}
  end

  defp page_title(:show), do: "Show Time"
  defp page_title(:edit), do: "Edit Time"
end
