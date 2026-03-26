defmodule Timertimer.Repo.Migrations.AddRoundNameToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :round_name, :string
    end
  end
end
