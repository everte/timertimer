defmodule Timertimer.Repo.Migrations.CreateAthletes do
  use Ecto.Migration

  def change do
    create table(:athletes) do
      add :name, :string
      add :short_name, :string
      add :birth_date, :date
      add :country, :string
      add :country2, :string
      add :gender, :string
      add :notes, :string

      timestamps(type: :utc_datetime)
    end
  end
end
