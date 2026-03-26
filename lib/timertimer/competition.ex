defmodule Timertimer.Competition do
  @moduledoc """
  The Competition context.
  """

  import Ecto.Query, warn: false
  alias Timertimer.Repo

  alias Timertimer.Competition.Athlete
  alias Timertimer.Competition.Match
  alias Phoenix.PubSub

  @pubsub_topic "db"

  # Convenience function for broadcasting database changes
  defp broadcast_change(event_type, data) do
    PubSub.broadcast(Timertimer.PubSub, @pubsub_topic, {event_type, data})
    data
  end

  @doc """
  Returns the list of athletes.

  ## Examples

      iex> list_athletes()
      [%Athlete{}, ...]

  """
  def list_athletes do
    Repo.all(from a in Athlete, order_by: a.name)
  end

  def find_athlete_by_short_name(name) do
    Repo.get_by(Athlete, short_name: name)
  end

  @doc """
  Gets a single athlete.

  Raises `Ecto.NoResultsError` if the Athlete does not exist.

  ## Examples

      iex> get_athlete!(123)
      %Athlete{}

      iex> get_athlete!(456)
      ** (Ecto.NoResultsError)

  """
  def get_athlete!(id), do: Repo.get!(Athlete, id)

  @doc """
  Creates a athlete.

  ## Examples

      iex> create_athlete(%{field: value})
      {:ok, %Athlete{}}

      iex> create_athlete(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_athlete(attrs \\ %{}) do
    %Athlete{}
    |> Athlete.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a athlete.

  ## Examples

      iex> update_athlete(athlete, %{field: new_value})
      {:ok, %Athlete{}}

      iex> update_athlete(athlete, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_athlete(%Athlete{} = athlete, attrs) do
    athlete
    |> Athlete.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a athlete.

  ## Examples

      iex> delete_athlete(athlete)
      {:ok, %Athlete{}}

      iex> delete_athlete(athlete)
      {:error, %Ecto.Changeset{}}

  """
  def delete_athlete(%Athlete{} = athlete) do
    Repo.delete(athlete)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking athlete changes.

  ## Examples

      iex> change_athlete(athlete)
      %Ecto.Changeset{data: %Athlete{}}

  """
  def change_athlete(%Athlete{} = athlete, attrs \\ %{}) do
    Athlete.changeset(athlete, attrs)
  end

  alias Timertimer.Competition.Time

  @doc """
  Returns the list of times.

  ## Examples

      iex> list_times()
      [%Time{}, ...]

  """
  def list_times do
    Repo.all(Time |> preload(:athlete))
  end

  def list_times_flop(params \\ %{}) do
    query =
      from t in Time,
        join: a in assoc(t, :athlete),
        as: :athlete,
        preload: [:athlete]

    Flop.validate_and_run(query, params, for: Time, replace_invalid_params: true)
  end

  @doc """
  Gets a single time.

  Raises `Ecto.NoResultsError` if the Time does not exist.

  ## Examples

      iex> get_time!(123)
      %Time{}

      iex> get_time!(456)
      ** (Ecto.NoResultsError)

  """
  def get_time!(id), do: Repo.get!(Time, id) |> Repo.preload(:athlete)

  @doc """
  Creates a time.

  ## Examples

      iex> create_time(%{field: value})
      {:ok, %Time{}}

      iex> create_time(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_time(attrs \\ %{}) do
    %Time{}
    |> Time.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, time} ->
        time_with_athlete = Repo.preload(time, :athlete)
        broadcast_change(:db_time, time_with_athlete)
        {:ok, time_with_athlete}

      error ->
        error
    end
  end

  @doc """
  Updates a time.

  ## Examples

      iex> update_time(time, %{field: new_value})
      {:ok, %Time{}}

      iex> update_time(time, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_time(%Time{} = time, attrs) do
    time
    |> Time.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_time} ->
        updated_time_with_athlete = Repo.preload(updated_time, :athlete)
        broadcast_change(:db_time, updated_time_with_athlete)
        {:ok, updated_time_with_athlete}

      error ->
        error
    end
  end

  @doc """
  Deletes a time.

  ## Examples

      iex> delete_time(time)
      {:ok, %Time{}}

      iex> delete_time(time)
      {:error, %Ecto.Changeset{}}

  """
  def delete_time(%Time{} = time) do
    Repo.delete(time)
    |> case do
      {:ok, deleted_time} ->
        broadcast_change(:db_time, deleted_time)
        {:ok, deleted_time}

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking time changes.

  ## Examples

      iex> change_time(time)
      %Ecto.Changeset{data: %Time{}}

  """
  def change_time(%Time{} = time, attrs \\ %{}) do
    Time.changeset(time, attrs)
  end

  def list_full_matches do
    Repo.all(
      from m in Match,
        preload: [
          :athlete1,
          :athlete2,
          :winner
        ]
    )
  end

  def list_full_matches(gender) do
    Repo.all(
      from m in Match,
        where: m.gender == ^gender,
        preload: [
          :athlete1,
          :athlete2,
          :winner
        ]
    )
  end

  def list_matches do
    matches = Repo.all(Match)

    athlete_ids =
      matches
      |> Enum.flat_map(fn match ->
        Enum.filter([match.athlete1_id, match.athlete2_id, match.winner_id], & &1)
      end)
      |> Enum.uniq()

    athletes =
      from(a in Athlete,
        where: a.id in ^athlete_ids,
        select: struct(a, ^(Athlete.__schema__(:fields) -- [:picture_data]))
      )
      |> Repo.all()
      |> Map.new(fn athlete -> {athlete.id, athlete} end)

    Enum.map(matches, fn match ->
      %{
        match
        | athlete1: Map.get(athletes, match.athlete1_id),
          athlete2: Map.get(athletes, match.athlete2_id),
          winner: Map.get(athletes, match.winner_id)
      }
    end)
  end

  def get_match!(id) do
    Repo.get!(Match, id)
    |> Repo.preload([:athlete1, :athlete2, :winner])
  end

  def create_match(attrs \\ %{}) do
    match =
      %Match{}
      |> Match.changeset(attrs)
      |> Repo.insert()

    broadcast_change(:db_match, match)
    match
  end

  def update_match(%Match{} = match, attrs) do
    updated_match =
      match
      |> Match.changeset(attrs)
      |> Repo.update()

    broadcast_change(:db_match, updated_match)
    updated_match
  end

  def delete_match(%Match{} = match) do
    Repo.delete(match)
    broadcast_change(:db_match, match)
  end

  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  def list_matches_with_preloads do
    Repo.all(
      from m in Match,
        preload: [
          athlete1: ^athlete_without_picture_query(),
          athlete2: ^athlete_without_picture_query(),
          winner: ^athlete_without_picture_query()
        ]
    )
  end

  def get_match_with_preloads!(id) do
    Repo.get!(Match, id)
    |> Repo.preload(
      athlete1: athlete_without_picture_query(),
      athlete2: athlete_without_picture_query(),
      winner: athlete_without_picture_query()
    )
  end

  def get_match_by_round_name(gender, round_name) do
    matches_query =
      from(m in Timertimer.Competition.Match,
        where: m.gender == ^gender and m.round_name == ^round_name
      )

    match = Repo.one(matches_query)

    if match do
      match_round = match.round

      Repo.preload(match,
        athlete1: {
          from(a in Timertimer.Competition.Athlete),
          [
            times:
              from(t in Timertimer.Competition.Time,
                where: t.round == ^match_round,
                order_by: [asc: t.start_time]
              )
          ]
        },
        athlete2: {
          from(a in Timertimer.Competition.Athlete),
          [
            times:
              from(t in Timertimer.Competition.Time,
                where: t.round == ^match_round,
                order_by: [asc: t.start_time]
              )
          ]
        }
      )
    else
      nil
    end
  end

  defp athlete_without_picture_query do
    from a in Timertimer.Competition.Athlete,
      select: struct(a, ^(Timertimer.Competition.Athlete.__schema__(:fields) -- [:picture_data]))
  end

  def get_top_three_times_for_athlete(athlete_id, round) do
    query =
      from t in Time,
        where: t.athlete_id == ^athlete_id and t.round == ^round,
        order_by: [asc: t.start_time],
        limit: 3,
        preload: [:athlete]

    Repo.all(query)
  end

  def list_athletes_for_select do
    from(a in Athlete,
      select: {a.name, a.id},
      order_by: a.name
    )
    |> Repo.all()
  end

  def get_athletes_by_best_time_in_round(round, gender) do
    best_times_subquery =
      from t in Time,
        where: t.round == ^round,
        group_by: t.athlete_id,
        select: %{athlete_id: t.athlete_id, best_time: min(t.time)}

    query =
      from a in Athlete,
        join: bt in subquery(best_times_subquery),
        on: a.id == bt.athlete_id,
        where: a.gender == ^gender,
        select: %{
          athlete: a,
          best_time: bt.best_time
        },
        order_by: [asc: bt.best_time]

    Repo.all(query)
  end

  def get_athletes_by_best_time_with_all_times(round, gender) do
    athletes_by_best_time =
      from a in Athlete,
        join: t in Time,
        on: a.id == t.athlete_id,
        where: a.gender == ^gender and t.round == ^round,
        group_by: a.id,
        select: %{
          athlete: a,
          best_time: min(t.time)
        },
        order_by: [asc: min(t.time)]

    athletes_with_best = Repo.all(athletes_by_best_time)

    Enum.map(athletes_with_best, fn %{athlete: athlete, best_time: best_time} ->
      times_query =
        from t in Time,
          where: t.athlete_id == ^athlete.id and t.round == ^round,
          select: t.time,
          order_by: [asc: t.start_time]

      all_times = Repo.all(times_query)

      %{
        athlete: athlete,
        best_time: best_time,
        all_times: all_times
      }
    end)
  end
end
