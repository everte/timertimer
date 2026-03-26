defmodule TimertimerWeb.Streaming.BracketsLive do
  alias TimertimerWeb.TimerComponents
  import TimerComponents
  alias Timertimer.Competition
  use Phoenix.LiveView

  @impl true
  def mount(params, _session, socket) do
    gender = (params["gender"] || "male") |> String.to_atom()
    matches = Competition.list_full_matches(gender)

    socket = assign_matches(socket, matches)
    {:ok, assign(socket, show_images: false, gender: gender) |> maybe_subscribe}
  end

  @impl true
  def handle_info({:db_match, _match}, socket) do
    socket = assign_matches(socket, Competition.list_full_matches(socket.assigns.gender))

    {:noreply, socket}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def filter_by_round_and_position(matches, round, position) do
    matches
    |> Enum.filter(fn match -> match.round == round and match.position == position end)
    |> List.first()
  end

  defp maybe_subscribe(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Timertimer.PubSub, "db")
    end

    socket
  end

  defp athlete_box_mappings do
    [
      # Quarter finals (8 athletes)
      # top left quarter 1
      {"box_a_1", {:quarter_1, :athlete1}},
      {"box_a_3", {:quarter_1, :athlete2}},

      # bottom left quarter 2
      {"box_a_5", {:quarter_2, :athlete1}},
      {"box_a_7", {:quarter_2, :athlete2}},

      # top right quarter 3
      {"box_a_2", {:quarter_3, :athlete1}},
      {"box_a_4", {:quarter_3, :athlete2}},

      # bottom right quarter 4
      {"box_a_6", {:quarter_4, :athlete1}},
      {"box_a_8", {:quarter_4, :athlete2}},

      # Semi-finals (4 athletes from quarter-finals moving on)
      # left half 1
      {"box_q_1_3", {:half_1, :athlete1}},
      {"box_q_5_7", {:half_1, :athlete2}},

      # right half 2
      {"box_q_2_4", {:half_2, :athlete1}},
      {"box_q_6_8", {:half_2, :athlete2}},

      # Finals (2 athletes)
      {"box_final_l", {:final, :athlete1}},
      {"box_final_r", {:final, :athlete2}},

      # Small finals / Bronze medal match (2 athletes)
      {"box_small_r", {:small_final, :athlete2}},
      {"box_sfinal_l", {:small_final, :athlete1}}
    ]
  end

  def assign_matches(socket, matches) do
    socket
    |> assign(:quarter_1, filter_by_round_and_position(matches, :quarter, 1))
    |> assign(:quarter_2, filter_by_round_and_position(matches, :quarter, 2))
    |> assign(:quarter_3, filter_by_round_and_position(matches, :quarter, 3))
    |> assign(:quarter_4, filter_by_round_and_position(matches, :quarter, 4))
    |> assign(:half_1, filter_by_round_and_position(matches, :half, 1))
    |> assign(:half_2, filter_by_round_and_position(matches, :half, 2))
    |> assign(:final, filter_by_round_and_position(matches, :final, 1))
    |> assign(:small_final, filter_by_round_and_position(matches, :small_final, 1))
  end

  defp get_box_dimensions(box_id) do
    dimensions = %{
      "box_final_r" => %{
        x: "981.16663",
        y: "246.58563",
        width: "240.35732",
        height: "349.61069",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      },
      "box_final_l" => %{
        x: "698.47595",
        y: "246.58566",
        width: "240.35732",
        height: "349.61069",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      },
      "box_small_r" => %{
        x: "981.77472",
        y: "735.11407",
        width: "169.6785",
        height: "246.80513",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      },
      "box_sfinal_l" => %{
        x: "768.54688",
        y: "735.11407",
        width: "169.6785",
        height: "246.80513",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      },
      "box_q_6_8" => %{
        x: "1321.7736",
        y: "613.6145",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_q_2_4" => %{
        x: "1321.7736",
        y: "272.65442",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_q_5_7" => %{
        x: "469.60172",
        y: "613.6145",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_q_1_3" => %{
        x: "469.60172",
        y: "272.65442",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_8" => %{
        x: "1603.5428",
        y: "801.38593",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_6" => %{
        x: "1603.5428",
        y: "561.88617",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_4" => %{
        x: "1601.5905",
        y: "322.38626",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_2" => %{
        x: "1603.5428",
        y: "82.886467",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_7" => %{
        x: "189.54829",
        y: "801.38593",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_5" => %{
        x: "189.54829",
        y: "561.88617",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_3" => %{
        x: "187.59587",
        y: "322.38626",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_a_1" => %{
        x: "189.54829",
        y: "82.886467",
        width: "128.8613",
        height: "187.43465",
        transform: "matrix(0.96049539,0,0,0.93279552,37.924423,36.2904)"
      },
      "box_inviz_title" => %{
        x: "379.63947",
        y: "0",
        width: "1160.7211",
        height: "147.73364",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      },
      "box_inviz_final_text" => %{
        x: "771.02362",
        y: "0",
        width: "377.95276",
        height: "90.708664",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      },
      "box_inviz_small_final_text" => %{
        x: "771.02362",
        y: "0",
        width: "377.95276",
        height: "65.0298",
        transform: "matrix(0.85759474,0,0,0.83286244,137.64674,86.954911)"
      }
    }

    box = dimensions[box_id]
    transform = Map.get(box, :transform)

    if transform do
      {box.x, box.y, box.width, box.height, transform}
    else
      {box.x, box.y, box.width, box.height}
    end
  end

  defp determine_box_width_class(box_id) do
    cond do
      String.starts_with?(box_id, "box_a_") -> "sm"
      String.starts_with?(box_id, "box_q") -> "sm"
      String.starts_with?(box_id, "box_final") -> "lg"
      String.starts_with?(box_id, "box_small") -> "md"
      String.starts_with?(box_id, "box_d_") -> "lg"
      true -> "md"
    end
  end
end
