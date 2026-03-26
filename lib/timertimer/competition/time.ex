defmodule Timertimer.Competition.Time do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:round, :inserted_at, :athlete_name, :time, :start_time],
    sortable: [:round, :athlete_name, :time, :inserted_at, :start_time],
    join_fields: [
      athlete_name: [binding: :athlete, field: :name]
    ],
    default_order: %{
      order_by: [:inserted_at],
      order_directions: [:desc]
    }
  }

  schema "times" do
    field :time, :integer
    field :time_string, :string, virtual: true

    field :round, Ecto.Enum,
      values: [:test, :training, :quarter, :half, :small_final, :final, :qualification]

    field :start_time, :utc_datetime
    belongs_to :athlete, Timertimer.Competition.Athlete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time, attrs) do
    time
    |> cast(attrs, [:time, :athlete_id, :round, :time_string, :start_time])
    |> maybe_put_start_time(time, attrs)
    |> validate_required([:time, :athlete_id, :round, :start_time])
    |> assoc_constraint(:athlete)
  end

  defp maybe_put_start_time(changeset, %{__meta__: %{state: :built}}, attrs) do
    start_time_provided? =
      Map.has_key?(attrs, "start_time") or Map.has_key?(attrs, :start_time)

    time_ms = Map.get(attrs, :time, Map.get(attrs, "time", 0))

    if !start_time_provided? do
      now =
        DateTime.utc_now()
        |> DateTime.add(-time_ms, :millisecond)
        |> DateTime.truncate(:second)

      put_change(changeset, :start_time, now)
    else
      changeset
    end
  end

  defp maybe_put_start_time(changeset, _time, _attrs), do: changeset
end
