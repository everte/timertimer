defmodule TimertimerWeb.AthleteLiveTest do
  use TimertimerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Timertimer.CompetitionFixtures

  @create_attrs %{name: "some name", short_name: "some short_name", birth_date: "2025-04-01", country: "some country", country2: "some country2", gender: :male, notes: "some notes"}
  @update_attrs %{name: "some updated name", short_name: "some updated short_name", birth_date: "2025-04-02", country: "some updated country", country2: "some updated country2", gender: :female, notes: "some updated notes"}
  @invalid_attrs %{name: nil, short_name: nil, birth_date: nil, country: nil, country2: nil, gender: nil, notes: nil}

  defp create_athlete(_) do
    athlete = athlete_fixture()
    %{athlete: athlete}
  end

  describe "Index" do
    setup [:create_athlete]

    test "lists all athletes", %{conn: conn, athlete: athlete} do
      {:ok, _index_live, html} = live(conn, ~p"/athletes")

      assert html =~ "Listing Athletes"
      assert html =~ athlete.name
    end

    test "saves new athlete", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/athletes")

      assert index_live |> element("a", "New Athlete") |> render_click() =~
               "New Athlete"

      assert_patch(index_live, ~p"/athletes/new")

      assert index_live
             |> form("#athlete-form", athlete: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#athlete-form", athlete: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/athletes")

      html = render(index_live)
      assert html =~ "Athlete created successfully"
      assert html =~ "some name"
    end

    test "updates athlete in listing", %{conn: conn, athlete: athlete} do
      {:ok, index_live, _html} = live(conn, ~p"/athletes")

      assert index_live |> element("#athletes-#{athlete.id} a", "Edit") |> render_click() =~
               "Edit Athlete"

      assert_patch(index_live, ~p"/athletes/#{athlete}/edit")

      assert index_live
             |> form("#athlete-form", athlete: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#athlete-form", athlete: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/athletes")

      html = render(index_live)
      assert html =~ "Athlete updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes athlete in listing", %{conn: conn, athlete: athlete} do
      {:ok, index_live, _html} = live(conn, ~p"/athletes")

      assert index_live |> element("#athletes-#{athlete.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#athletes-#{athlete.id}")
    end
  end

  describe "Show" do
    setup [:create_athlete]

    test "displays athlete", %{conn: conn, athlete: athlete} do
      {:ok, _show_live, html} = live(conn, ~p"/athletes/#{athlete}")

      assert html =~ "Show Athlete"
      assert html =~ athlete.name
    end

    test "updates athlete within modal", %{conn: conn, athlete: athlete} do
      {:ok, show_live, _html} = live(conn, ~p"/athletes/#{athlete}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Athlete"

      assert_patch(show_live, ~p"/athletes/#{athlete}/show/edit")

      assert show_live
             |> form("#athlete-form", athlete: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#athlete-form", athlete: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/athletes/#{athlete}")

      html = render(show_live)
      assert html =~ "Athlete updated successfully"
      assert html =~ "some updated name"
    end
  end
end
