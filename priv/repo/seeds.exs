# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Timertimer.Repo.insert!(%Timertimer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Timertimer.Competition.Seeds do
  alias Timertimer.Repo
  alias Timertimer.Competition.Athlete

  def import_athletes do
    athletes = [
      %{
        name: "Jessica Levine",
        short_name: "F",
        birth_date: ~D[1976-12-03],
        country: "Belgium",
        gender: :female
      },
      %{
        name: "Mélanie Béguelin",
        short_name: "F",
        birth_date: ~D[1994-10-13],
        country: "Switzerland",
        gender: :female
      },
      %{
        name: "Emma Domenech",
        short_name: "F",
        birth_date: ~D[1998-01-21],
        country: "France",
        gender: :female
      },
      %{
        name: "Moritz Hollich",
        short_name: "M",
        birth_date: ~D[2000-05-28],
        country: "Germany",
        gender: :male
      },
      %{
        name: "Jeroen Cuppen",
        short_name: "M",
        birth_date: ~D[2004-01-03],
        country: "Netherlands",
        gender: :male
      },
      %{
        name: "Alexis Duponchel",
        short_name: "M",
        birth_date: ~D[1997-11-12],
        country: "France",
        gender: :male
      },
      %{
        name: "Stijn Vandenbussche",
        short_name: "M",
        birth_date: ~D[1991-08-02],
        country: "Belgium",
        gender: :male
      },
      %{
        name: "Gonzalo Caturelli",
        short_name: "M",
        birth_date: ~D[1995-12-03],
        country: "Argentina",
        gender: :male
      },
      %{
        name: "Rafaele Marie",
        short_name: "F",
        birth_date: ~D[1992-12-01],
        country: "France",
        gender: :female
      },
      %{
        name: "Dothée Janis",
        short_name: "M",
        birth_date: ~D[1995-03-24],
        country: "Belgium",
        gender: :male
      },
      %{
        name: "Cristian felipe forero navarro",
        short_name: "M",
        birth_date: ~D[1999-05-13],
        country: "Colombia",
        gender: :male
      },
      %{
        name: "Hugo Labarre",
        short_name: "M",
        birth_date: ~D[1997-05-05],
        country: "France",
        gender: :male
      },
      %{
        name: "Jakub Morawski",
        short_name: "M",
        birth_date: ~D[1996-12-04],
        country: "Poland",
        gender: :male
      },
      %{
        name: "Dyan Enghard",
        short_name: "M",
        birth_date: ~D[1997-10-05],
        country: "Switzerland",
        gender: :male
      },
      %{
        name: "Julie Engelen",
        short_name: "F",
        birth_date: ~D[1995-05-16],
        country: "Belgium",
        gender: :female
      },
      %{
        name: "Sascha Grill",
        short_name: "M",
        birth_date: ~D[2001-08-29],
        country: "Germany",
        gender: :male
      },
      %{
        name: "Solène Moreau",
        short_name: "F",
        birth_date: ~D[1997-08-16],
        country: "France",
        gender: :female
      },
      %{
        name: "Jef Cox",
        short_name: "M",
        birth_date: ~D[1990-08-18],
        country: "Belgium",
        gender: :male
      },
      %{
        name: "Cecilia Stock",
        short_name: "F",
        birth_date: ~D[1995-10-02],
        country: "Germany",
        gender: :female
      },
      %{
        name: "Dorothea Hamilton",
        short_name: "F",
        birth_date: ~D[1986-12-27],
        country: "Germany",
        gender: :female
      },
      %{
        name: "Yann valais",
        short_name: "M",
        birth_date: ~D[1994-07-08],
        country: "France",
        gender: :male
      },
      %{
        name: "Alexandra Kraienhorst",
        short_name: "F",
        birth_date: ~D[1986-10-07],
        country: "Germany",
        gender: :female
      },
      %{
        name: "Archie Williams",
        short_name: "M",
        birth_date: ~D[1999-09-09],
        country: "Luxembourg",
        gender: :male
      },
      %{
        name: "Mateus Stoco Vidal",
        short_name: "M",
        birth_date: ~D[1994-07-01],
        country: "Brazil",
        gender: :male
      }
    ]

    Enum.each(athletes, fn athlete_data ->
      changeset = Athlete.changeset(%Athlete{}, athlete_data)

      case Repo.insert(changeset) do
        {:ok, _athlete} -> IO.puts("Athlete #{athlete_data[:name]} inserted successfully.")
        {:error, _changeset} -> IO.puts("Failed to insert athlete #{athlete_data[:name]}.")
      end
    end)
  end
end

Timertimer.Competition.Seeds.import_athletes()
