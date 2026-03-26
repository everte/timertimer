defmodule Timertimer.Repo.Migrations.AddGenderToMatches do
  use Ecto.Migration

  def change do
    alter table(:matches) do
      add :gender, :string
    end
  end
end
