defmodule TimertimerWeb.PageController do
  use TimertimerWeb, :controller

  alias Timertimer.Competition

  @spec home(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def home(conn, _params) do
    base_url = TimertimerWeb.Endpoint.url()

    athletes =
      Competition.list_athletes()
      |> Enum.map(&Map.put(&1, :url_picture, create_svo_url(base_url, &1.short_name, "picture")))
      |> Enum.map(&Map.put(&1, :url_name, create_svo_url(base_url, &1.short_name, "name")))

    matches =
      Competition.list_matches()
      |> Enum.map(&Map.put(&1, :url, create_match_url(base_url, &1.round_name, &1.gender)))

    conn =
      conn
      |> assign(:athletes, athletes)
      |> assign(:base_url, base_url)
      |> assign(:matches, matches)

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  defp create_svo_url(base, name, kind) do
    base <> "/embed/stream/svo/" <> name <> "/" <> kind
  end

  defp create_match_url(base, round, gender) do
    base <> "/embed/stream/vs/" <> round <> "/" <> Atom.to_string(gender)
  end
end
