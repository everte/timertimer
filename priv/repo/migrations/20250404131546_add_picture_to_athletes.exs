defmodule Timertimer.Repo.Migrations.AddPictureToAthletes do
  use Ecto.Migration

  def change do
    alter table(:athletes) do
      add :picture_data, :binary
    end
  end
end
