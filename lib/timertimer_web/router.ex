defmodule TimertimerWeb.Router do
  use TimertimerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TimertimerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Similar to default `:browser` pipeline, but with one more plug
  # `:allow_iframe` to allow embedding in an iframe
  # We need this for the "H2R" application used for streaming
  pipeline :embedded do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TimertimerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :allow_iframe
  end

  # TODO: improve this ugly hack/workaround
  defp allow_iframe(conn, _opts) do
    conn
    |> delete_resp_header("x-frame-options")
    |> delete_resp_header("content-security-policy")
  end

  scope "/embed", TimertimerWeb do
    pipe_through [:embedded]

    live "/stream/timer", Streaming.TimerLive
    live "/stream/rankings/qualification/:gender", Streaming.QualificationRankingLive
    live "/stream/rankings/:round/:gender", Streaming.RankingLive
    live "/stream/svo/:name/:type", Streaming.SvoLive
    live "/stream/vs/:round/:gender", Streaming.VsLive
    live "/stream/brackets/:gender", Streaming.BracketsLive
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TimertimerWeb do
    pipe_through :browser

    get "/", PageController, :home
    # admin pages
    # no security currently, we are on a trusted network with trusted people
    scope "/admin" do
      live "/athletes", AthleteLive.Index, :index
      live "/athletes/new", AthleteLive.Index, :new
      live "/athletes/:id/edit", AthleteLive.Index, :edit

      live "/athletes/:id", AthleteLive.Show, :show
      live "/athletes/:id/show/edit", AthleteLive.Show, :edit
      live "/times", TimeLive.Index, :index
      live "/times/new", TimeLive.Index, :new
      live "/times/:id/edit", TimeLive.Index, :edit

      live "/times/:id", TimeLive.Show, :show
      live "/times/:id/show/edit", TimeLive.Show, :edit

      live "/matches", MatchLive.Index, :index
      live "/matches/new", MatchLive.Index, :new
      live "/matches/:id/edit", MatchLive.Index, :edit
      live "/matches/:id", MatchLive.Show, :show

      live "/timer", AdminLive
    end

    # prefix all 'public' streaming pages with /stream
    scope "/stream" do
      live "/brackets/:gender", Streaming.BracketsLive
      live "/timer", Streaming.TimerLive
      live "/rankings/qualification/:gender", Streaming.QualificationRankingLive
      live "/rankings/:round/:gender", Streaming.RankingLive
      live "/svo/:name/:type", Streaming.SvoLive
      live "/vs/:round/:gender", Streaming.VsLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TimertimerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:timertimer, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TimertimerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
