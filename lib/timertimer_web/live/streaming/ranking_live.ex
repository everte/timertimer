# lib/timertimer_web/live/athlete_time_live.ex
defmodule TimertimerWeb.Streaming.RankingLive do
  use Phoenix.LiveView
  alias TimertimerWeb.TimerComponents
  import TimerComponents
  alias Timertimer.Competition
  alias Timertimer.Competition.Match

  @impl true
  def mount(params, _session, socket) do
    gender = (params["gender"] || "male") |> String.to_atom()
    round = params["round"] |> String.to_atom()

    {:ok,
     assign(socket,
       athletes: load_athletes(round, gender),
       title: build_title(round, gender),
       gender: gender,
       round: round
     )
     |> maybe_subscribe}
  end

  @impl true
  def handle_info({:db_time, _time}, socket) do
    socket = assign(socket, athletes: load_athletes(socket.assigns.round, socket.assigns.gender))
    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def load_athletes(round, gender) do
    Competition.get_athletes_by_best_time_with_all_times(round, gender)
    |> Enum.with_index(1)
    |> Enum.map(fn {athlete_data, index} ->
      Map.put(athlete_data, :rank, index)
    end)
  end

  defp build_title(round, gender),
    do: "#{Match.get_gender_name(gender)} #{Match.get_round_name(round)}"

  defp get_top_athletes(athletes, round) do
    case round do
      :test -> Enum.slice(athletes, 0, 8)
      :qualification -> Enum.slice(athletes, 0, 8)
      :quarter_final -> Enum.slice(athletes, 0, 4)
      :semi_final -> Enum.slice(athletes, 0, 2)
      _ -> Enum.slice(athletes, 0, 4)
    end
  end

  defp maybe_subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Timertimer.PubSub, "db")
    end

    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tv flex">
      <div class="flex-auto">

        <h1 class="mt-56 mb-10">
          {@title}
        </h1>

        <table class="table-fixed border-separate border-spacing-x-8 border-spacing-y-4 mx-auto items-center bg-white">
          <thead>
            <tr class="text-center text-tvRed">
              <th class="w-8 max-w-8 whitespace-nowrap">Top 8</th>
              <th class="w-[40rem]" />
              <th class="w-40">BEST</th>
              <th class="w-40">RUN 1</th>
              <th class="w-40">RUN 2</th>
            </tr>
          </thead>
          <tbody>
            <%= for athlete <- get_top_athletes(@athletes, @round) do %>
              <tr>
                <td class="text-center text-tvRed">
                  {athlete.rank}
                </td>
                <td class="flex items-center gap-x-2">
                  <.render_flag country={athlete.athlete.country2} style="w-10" />
                  <.render_flag country={athlete.athlete.country} style="w-10 mr-3" />
                  <% [first_name | last_name] = String.split(athlete.athlete.name, " ", parts: 2)%>
                  <span class="label-firstName">{first_name}</span>
                  <span class="label-lastName">{last_name}</span>
                </td>
                <td class="mx-16 text-center label-time-em">
                  {if athlete.best_time,
                    do: Timertimer.Timer.format_ms(athlete.best_time),
                    else: "-"}
                </td>
                <td class="mx-4 text-center label-time">
                  {if t = Enum.at(athlete.all_times, 0),
                    do: Timertimer.Timer.format_ms(t),
                    else: "-"}
                </td>
                <td class="mx-4 text-center label-time">
                  {if t = Enum.at(athlete.all_times, 1),
                    do: Timertimer.Timer.format_ms(t),
                    else: "-"}
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
