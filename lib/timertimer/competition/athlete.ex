defmodule Timertimer.Competition.Athlete do
  use Ecto.Schema
  import Ecto.Changeset

  schema "athletes" do
    field :name, :string
    field :short_name, :string
    field :birth_date, :date
    field :country, :string
    field :country2, :string
    field :gender, Ecto.Enum, values: [:male, :female]
    field :notes, :string
    field :picture_data, :binary

    has_many :times, Timertimer.Competition.Time

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(athlete, attrs) do
    athlete
    |> cast(attrs, [
      :name,
      :short_name,
      :birth_date,
      :country,
      :country2,
      :gender,
      :notes,
      :picture_data
    ])
    |> validate_required([:name, :short_name, :birth_date, :country, :gender])
  end
end
