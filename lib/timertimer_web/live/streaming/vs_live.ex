defmodule TimertimerWeb.Streaming.VsLive do
  use Phoenix.LiveView
  alias TimertimerWeb.TimerComponents
  import TimerComponents
  alias Timertimer.Competition
  alias Timertimer.Competition.Match

  @impl true
  def mount(params, _session, socket) do
    gender = params["gender"] |> String.to_atom()
    round = params["round"]
    match = load_match(gender, round)

    {:ok,
     assign(socket,
       match: match,
       title: build_title(match.round, gender, match),
       gender: gender,
       round: round
     )
     |> maybe_subscribe()}
  end

  @impl true
  def handle_info({:db_time, _time}, socket) do
    socket = assign(socket, match: load_match(socket.assigns.gender, socket.assigns.round))
    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp maybe_subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Timertimer.PubSub, "db")
    end

    socket
  end

  defp load_match(gender, round_name) do
    Competition.get_match_by_round_name(gender, round_name)
  end

  defp build_title(round, gender, _match),
    do: "#{Match.get_gender_name(gender)} #{Match.get_round_name(round)}"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="tv">
      <h1 class="pt-28 pb-6">
        {@title}
      </h1>
      <table class="table-fixed border-separate border-spacing-x-8 border-spacing-y-3 mx-auto items-center text-4xl text-tvBlue-dark uppercase text-center">
        <tbody>
          <tr>
            <td class="pb-3">
              <.svo_picture
                name={@match.athlete1.name}
                countries={[@match.athlete1.country, @match.athlete1.country2]}
                picture_data={@match.athlete1.picture_data}
                size="big-vs"
              />
            </td>
            <td class="text-center w-1/3">
              <p class="font-tvBold text-[16rem] text-white text-outline-black">
                VS
              </p>
            </td>
            <td class="pb-3">
              <.svo_picture
                name={@match.athlete2.name}
                countries={[@match.athlete2.country, @match.athlete2.country2]}
                picture_data={@match.athlete2.picture_data}
                size="big-vs"
              />
            </td>
          </tr>
          <%= for i <- 0..2 do %>
            <% time1 = Enum.at(@match.athlete1.times || [], i)
            time2 = Enum.at(@match.athlete2.times || [], i)

            style1 =
              if(time1 && time2 && time1.time <= time2.time, do: "label-time-em", else: "label-time")

            style2 =
              if(time1 && time2 && time2.time <= time1.time, do: "label-time-em", else: "label-time") %>

            <tr>
              <td class={"bg-white p-3 #{style1} text-5xl"}>
                {if time1, do: Timertimer.Timer.format_ms(time1.time), else: "-"}
              </td>
              <td class="text-center">
                <h3>
                  run {i + 1}
                </h3>
              </td>
              <td class={"bg-white p-3 #{style2} text-5xl"}>
                {if time2, do: Timertimer.Timer.format_ms(time2.time), else: "-"}
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
