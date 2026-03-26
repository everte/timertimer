# lib/timertimer_web/live/athlete_time_live.ex
defmodule TimertimerWeb.Streaming.QualificationRankingLive do
  use Phoenix.LiveView
  alias TimertimerWeb.TimerComponents
  import TimerComponents
  alias Timertimer.Competition
  alias Timertimer.Competition.Match

  @impl true
  def mount(params, _session, socket) do
    gender = (params["gender"] || "male") |> String.to_atom()
    round = :qualification

    hide_headings =
      if Map.get(params, "noheadings", "false") in ["true", ""], do: true, else: false

    rows_param = Map.get(params, "rows", "default")

    display_rows =
      cond do
        rows_param == "none" ->
          nil

        rows_param == "all" ->
          [1, nil]

        String.match?(rows_param, ~r/^\d+-\d+$/) ->
          String.split(rows_param, "-") |> Enum.map(&String.to_integer/1)

        true ->
          [1, 8]
      end

    {:ok,
     assign(socket,
       athletes: load_athletes(round, gender, display_rows),
       title: build_title(round, gender),
       gender: gender,
       round: round,
       display_rows: display_rows,
       hide_headings: hide_headings
     )
     |> maybe_subscribe}
  end

  @impl true
  def handle_info({:db_time, _time}, socket) do
    socket =
      assign(socket,
        athletes:
          load_athletes(socket.assigns.round, socket.assigns.gender, socket.assigns.display_rows)
      )

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def load_athletes(round, gender, display_rows) do
    athletes =
      Competition.get_athletes_by_best_time_with_all_times(round, gender)
      |> Enum.with_index(1)
      |> Enum.map(fn {athlete_data, index} ->
        Map.put(athlete_data, :rank, index)
      end)

    case display_rows do
      nil -> []
      [first, nil] -> Enum.slice(athletes, (first - 1)..-1)
      [first, last] -> Enum.slice(athletes, (first - 1)..(last - 1))
      _ -> []
    end
  end

  defp build_title(round, gender),
    do: "#{Match.get_gender_name(gender)} #{Match.get_round_name(round)}"

  defp maybe_subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Timertimer.PubSub, "db")
    end

    socket
  end

  @impl true
  def render(assigns) do
    visiblilty_class = if assigns.hide_headings, do: "invisible", else: ""

    assigns =
      assigns
      |> assign(:visiblilty_class, visiblilty_class)

    ~H"""
    <!-- img class="w-96 absolute top-0 right-0" src="/images/logo_cloud.svg"/-->
    <div class="tv flex">
      <div class="flex-auto">
        <h1 class={"mt-36 mb-12 #{@visiblilty_class}"}>
          {@title}
        </h1>
        <div class="flex flex-col w-[66%] max-w-[66%] mx-auto">
          <table class={"tvTable mb-4 #{@visiblilty_class}"}>
            <thead>
              <tr class="text-center text-tvRed">
                <th class="w-8 max-w-8 whitespace-nowrap">Rankings</th>
                <th class="" />
                <th class="w-40">BEST</th>
                <th class="w-40">RUN 1</th>
                <th class="w-40">RUN 2</th>
              </tr>
            </thead>
          </table>
          <table class="tvTable">
            <tbody class="bg-white">
              <%= for athlete <- @athletes do %>
                <tr>
                  <td class="text-center text-tvRed">
                    {athlete.rank}
                  </td>
                  <td class="flex items-center gap-x-2">
                    <.render_flag country={athlete.athlete.country2} style="w-10" />
                    <.render_flag country={athlete.athlete.country} style="w-10 mr-3" />
                    <% [first_name | last_name] = String.split(athlete.athlete.name, " ", parts: 2) %>
                    <span class="label-firstName">{first_name}</span>
                    <span class="label-lastName">{last_name}</span>
                  </td>
                  <td class="mx-16 text-center label-time-em w-40">
                    {if athlete.best_time,
                      do: Timertimer.Timer.format_ms(athlete.best_time),
                      else: "-"}
                  </td>
                  <td class="mx-4 text-center label-time w-40">
                    {if t = Enum.at(athlete.all_times, 0),
                      do: Timertimer.Timer.format_ms(t),
                      else: "-"}
                  </td>
                  <td class="mx-4 text-center label-time w-40">
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
    </div>
    """
  end
end
