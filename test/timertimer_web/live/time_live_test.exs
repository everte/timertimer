defmodule TimertimerWeb.TimeLiveTest do
  use TimertimerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Timertimer.CompetitionFixtures

  @create_attrs %{time: 42}
  @update_attrs %{time: 43}
  @invalid_attrs %{time: nil}

  defp create_time(_) do
    time = time_fixture()
    %{time: time}
  end

  describe "Index" do
    setup [:create_time]

    test "lists all times", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/times")

      assert html =~ "Listing Times"
    end

    test "saves new time", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/times")

      assert index_live |> element("a", "New Time") |> render_click() =~
               "New Time"

      assert_patch(index_live, ~p"/times/new")

      assert index_live
             |> form("#time-form", time: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#time-form", time: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/times")

      html = render(index_live)
      assert html =~ "Time created successfully"
    end

    test "updates time in listing", %{conn: conn, time: time} do
      {:ok, index_live, _html} = live(conn, ~p"/times")

      assert index_live |> element("#times-#{time.id} a", "Edit") |> render_click() =~
               "Edit Time"

      assert_patch(index_live, ~p"/times/#{time}/edit")

      assert index_live
             |> form("#time-form", time: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#time-form", time: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/times")

      html = render(index_live)
      assert html =~ "Time updated successfully"
    end

    test "deletes time in listing", %{conn: conn, time: time} do
      {:ok, index_live, _html} = live(conn, ~p"/times")

      assert index_live |> element("#times-#{time.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#times-#{time.id}")
    end
  end

  describe "Show" do
    setup [:create_time]

    test "displays time", %{conn: conn, time: time} do
      {:ok, _show_live, html} = live(conn, ~p"/times/#{time}")

      assert html =~ "Show Time"
    end

    test "updates time within modal", %{conn: conn, time: time} do
      {:ok, show_live, _html} = live(conn, ~p"/times/#{time}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Time"

      assert_patch(show_live, ~p"/times/#{time}/show/edit")

      assert show_live
             |> form("#time-form", time: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#time-form", time: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/times/#{time}")

      html = render(show_live)
      assert html =~ "Time updated successfully"
    end
  end
end
