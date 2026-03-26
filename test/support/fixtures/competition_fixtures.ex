defmodule Timertimer.CompetitionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Timertimer.Competition` context.
  """

  @doc """
  Generate a athlete.
  """
  def athlete_fixture(attrs \\ %{}) do
    {:ok, athlete} =
      attrs
      |> Enum.into(%{
        birth_date: ~D[2025-04-01],
        country: "some country",
        country2: "some country2",
        gender: :male,
        name: "some name",
        notes: "some notes",
        short_name: "some short_name"
      })
      |> Timertimer.Competition.create_athlete()

    athlete
  end

  @doc """
  Generate a time.
  """
  def time_fixture(attrs \\ %{}) do
    {:ok, time} =
      attrs
      |> Enum.into(%{
        time: 42
      })
      |> Timertimer.Competition.create_time()

    time
  end
end
