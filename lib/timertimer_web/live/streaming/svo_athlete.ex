defmodule TimertimerWeb.Streaming.SvoLive do
  use Phoenix.LiveView
  alias TimertimerWeb.TimerComponents
  import TimerComponents
  alias Timertimer.Competition

  @default_athlete %Timertimer.Competition.Athlete{
    name: "Unknown",
    short_name: "unknown",
    country: "bel",
    gender: :male
  }

  @impl true
  def mount(params, _session, socket) do
    name = params["name"]
    type = params["type"]

    athlete = Competition.find_athlete_by_short_name(name) || @default_athlete
    {:ok, assign(socket, athlete: athlete, type: type)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tv">
      <div class="absolute bottom-28 left-28">
        <%= if @type == "name"  do %>
          <.svo_name name={@athlete.name} countries={[@athlete.country, @athlete.country2]} />
        <% end %>

        <%= if @type == "picture" do %>
          <.svo_picture
            name={@athlete.name}
            countries={[@athlete.country, @athlete.country2]}
            picture_data={@athlete.picture_data}
            size= "small-svo"
          />
        <% end %>
      </div>
    </div>
    """
  end
end
