defmodule Timertimer.Competition.Match do
  use Ecto.Schema

  schema "matches" do
    field :round, Ecto.Enum,
      values: [:test, :qualification, :quarter, :half, :small_final, :final]

    # for ordering within the round
    field :position, :integer

    field :round_name, :string
    field :gender, Ecto.Enum, values: [:male, :female]

    belongs_to :athlete1, Timertimer.Competition.Athlete
    belongs_to :athlete2, Timertimer.Competition.Athlete
    belongs_to :winner, Timertimer.Competition.Athlete

    timestamps()
  end

  def changeset(match, attrs) do
    match
    |> Ecto.Changeset.cast(attrs, [
      :round,
      :round_name,
      :gender,
      :position,
      :athlete1_id,
      :athlete2_id,
      :winner_id
    ])
    |> Ecto.Changeset.validate_required([
      :round,
      :round_name,
      :gender,
      :position
    ])
    |> Ecto.Changeset.assoc_constraint(:athlete1)
    |> Ecto.Changeset.assoc_constraint(:athlete2)
    |> Ecto.Changeset.assoc_constraint(:winner)
  end

  def get_round_name(round) do
    get_round(round)
  end

  def get_gender_name(gender) do
    get_gender(gender)
  end

  defp get_round(:test), do: "test round"
  defp get_round(:qualification), do: "qualifications"
  defp get_round(:quarter), do: "quarter-finals"
  defp get_round(:half), do: "semi-finals"
  defp get_round(:small_final), do: "small-finals"
  defp get_round(:final), do: "finals"
  defp get_round(_), do: "all rounds"

  defp get_gender(:male), do: "men's"
  defp get_gender(:female), do: "women's"
end
