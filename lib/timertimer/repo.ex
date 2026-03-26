defmodule Timertimer.Repo do
  use Ecto.Repo,
    otp_app: :timertimer,
    adapter: Ecto.Adapters.SQLite3
end
