defmodule Timertimer.CompetitionTest do
  use Timertimer.DataCase

  alias Timertimer.Competition

  describe "athletes" do
    alias Timertimer.Competition.Athlete

    import Timertimer.CompetitionFixtures

    @invalid_attrs %{name: nil, short_name: nil, birth_date: nil, country: nil, country2: nil, gender: nil, notes: nil}

    test "list_athletes/0 returns all athletes" do
      athlete = athlete_fixture()
      assert Competition.list_athletes() == [athlete]
    end

    test "get_athlete!/1 returns the athlete with given id" do
      athlete = athlete_fixture()
      assert Competition.get_athlete!(athlete.id) == athlete
    end

    test "create_athlete/1 with valid data creates a athlete" do
      valid_attrs = %{name: "some name", short_name: "some short_name", birth_date: ~D[2025-04-01], country: "some country", country2: "some country2", gender: :male, notes: "some notes"}

      assert {:ok, %Athlete{} = athlete} = Competition.create_athlete(valid_attrs)
      assert athlete.name == "some name"
      assert athlete.short_name == "some short_name"
      assert athlete.birth_date == ~D[2025-04-01]
      assert athlete.country == "some country"
      assert athlete.country2 == "some country2"
      assert athlete.gender == :male
      assert athlete.notes == "some notes"
    end

    test "create_athlete/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competition.create_athlete(@invalid_attrs)
    end

    test "update_athlete/2 with valid data updates the athlete" do
      athlete = athlete_fixture()
      update_attrs = %{name: "some updated name", short_name: "some updated short_name", birth_date: ~D[2025-04-02], country: "some updated country", country2: "some updated country2", gender: :female, notes: "some updated notes"}

      assert {:ok, %Athlete{} = athlete} = Competition.update_athlete(athlete, update_attrs)
      assert athlete.name == "some updated name"
      assert athlete.short_name == "some updated short_name"
      assert athlete.birth_date == ~D[2025-04-02]
      assert athlete.country == "some updated country"
      assert athlete.country2 == "some updated country2"
      assert athlete.gender == :female
      assert athlete.notes == "some updated notes"
    end

    test "update_athlete/2 with invalid data returns error changeset" do
      athlete = athlete_fixture()
      assert {:error, %Ecto.Changeset{}} = Competition.update_athlete(athlete, @invalid_attrs)
      assert athlete == Competition.get_athlete!(athlete.id)
    end

    test "delete_athlete/1 deletes the athlete" do
      athlete = athlete_fixture()
      assert {:ok, %Athlete{}} = Competition.delete_athlete(athlete)
      assert_raise Ecto.NoResultsError, fn -> Competition.get_athlete!(athlete.id) end
    end

    test "change_athlete/1 returns a athlete changeset" do
      athlete = athlete_fixture()
      assert %Ecto.Changeset{} = Competition.change_athlete(athlete)
    end
  end

  describe "times" do
    alias Timertimer.Competition.Time

    import Timertimer.CompetitionFixtures

    @invalid_attrs %{time: nil}

    test "list_times/0 returns all times" do
      time = time_fixture()
      assert Competition.list_times() == [time]
    end

    test "get_time!/1 returns the time with given id" do
      time = time_fixture()
      assert Competition.get_time!(time.id) == time
    end

    test "create_time/1 with valid data creates a time" do
      valid_attrs = %{time: 42}

      assert {:ok, %Time{} = time} = Competition.create_time(valid_attrs)
      assert time.time == 42
    end

    test "create_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Competition.create_time(@invalid_attrs)
    end

    test "update_time/2 with valid data updates the time" do
      time = time_fixture()
      update_attrs = %{time: 43}

      assert {:ok, %Time{} = time} = Competition.update_time(time, update_attrs)
      assert time.time == 43
    end

    test "update_time/2 with invalid data returns error changeset" do
      time = time_fixture()
      assert {:error, %Ecto.Changeset{}} = Competition.update_time(time, @invalid_attrs)
      assert time == Competition.get_time!(time.id)
    end

    test "delete_time/1 deletes the time" do
      time = time_fixture()
      assert {:ok, %Time{}} = Competition.delete_time(time)
      assert_raise Ecto.NoResultsError, fn -> Competition.get_time!(time.id) end
    end

    test "change_time/1 returns a time changeset" do
      time = time_fixture()
      assert %Ecto.Changeset{} = Competition.change_time(time)
    end
  end
end
