defmodule GaslightWeb.SongLiveTest do
  use GaslightWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Gaslight.Markov

  @create_attrs %{artist: "some artist", genius_lyrics: "some genius_lyrics", songs: []}
  @update_attrs %{artist: "some updated artist", genius_lyrics: "some updated genius_lyrics", songs: []}
  @invalid_attrs %{artist: nil, genius_lyrics: nil, songs: nil}

  defp fixture(:song) do
    {:ok, song} = Markov.create_song(@create_attrs)
    song
  end

  defp create_song(_) do
    song = fixture(:song)
    %{song: song}
  end

  describe "Index" do
    setup [:create_song]

    test "lists all songs", %{conn: conn, song: song} do
      {:ok, _index_live, html} = live(conn, Routes.song_index_path(conn, :index))

      assert html =~ "Listing Songs"
      assert html =~ song.artist
    end

    test "saves new song", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.song_index_path(conn, :index))

      assert index_live |> element("a", "New Song") |> render_click() =~
               "New Song"

      assert_patch(index_live, Routes.song_index_path(conn, :new))

      assert index_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#song-form", song: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.song_index_path(conn, :index))

      assert html =~ "Song created successfully"
      assert html =~ "some artist"
    end

    test "updates song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, Routes.song_index_path(conn, :index))

      assert index_live |> element("#song-#{song.id} a", "Edit") |> render_click() =~
               "Edit Song"

      assert_patch(index_live, Routes.song_index_path(conn, :edit, song))

      assert index_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#song-form", song: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.song_index_path(conn, :index))

      assert html =~ "Song updated successfully"
      assert html =~ "some updated artist"
    end

    test "deletes song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, Routes.song_index_path(conn, :index))

      assert index_live |> element("#song-#{song.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#song-#{song.id}")
    end
  end

  describe "Show" do
    setup [:create_song]

    test "displays song", %{conn: conn, song: song} do
      {:ok, _show_live, html} = live(conn, Routes.song_show_path(conn, :show, song))

      assert html =~ "Show Song"
      assert html =~ song.artist
    end

    test "updates song within modal", %{conn: conn, song: song} do
      {:ok, show_live, _html} = live(conn, Routes.song_show_path(conn, :show, song))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Song"

      assert_patch(show_live, Routes.song_show_path(conn, :edit, song))

      assert show_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#song-form", song: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.song_show_path(conn, :show, song))

      assert html =~ "Song updated successfully"
      assert html =~ "some updated artist"
    end
  end
end
