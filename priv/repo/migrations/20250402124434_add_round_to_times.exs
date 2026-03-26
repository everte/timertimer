defmodule Timertimer.Repo.Migrations.AddRoundToTimes do
  use Ecto.Migration

  def change do
    alter table(:times) do
      add :round, :string
    end
  end
end
