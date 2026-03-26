defmodule Timertimer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :ets.new(:session, [:named_table, :public, read_concurrency: true])

    children = [
      TimertimerWeb.Telemetry,
      Timertimer.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:timertimer, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:timertimer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Timertimer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Timertimer.Finch},
      # Start a worker by calling: Timertimer.Worker.start_link(arg)
      # {Timertimer.Worker, arg},
      # Start to serve requests, typically the last entry
      TimertimerWeb.Endpoint,
      Timertimer.TimerManager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Timertimer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TimertimerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
