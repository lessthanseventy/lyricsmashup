defmodule Lyricsmashup.MarkovTest do
  use Lyricsmashup.DataCase

  alias Lyricsmashup.Markov

  describe "songs" do
    alias Lyricsmashup.Markov.Song

    @valid_attrs %{artist: "some artist", genius_lyrics: "some genius_lyrics", songs: []}
    @update_attrs %{artist: "some updated artist", genius_lyrics: "some updated genius_lyrics", songs: []}
    @invalid_attrs %{artist: nil, genius_lyrics: nil, songs: nil}

    def song_fixture(attrs \\ %{}) do
      {:ok, song} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Markov.create_song()

      song
    end

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Markov.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Markov.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      assert {:ok, %Song{} = song} = Markov.create_song(@valid_attrs)
      assert song.artist == "some artist"
      assert song.genius_lyrics == "some genius_lyrics"
      assert song.songs == []
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Markov.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      assert {:ok, %Song{} = song} = Markov.update_song(song, @update_attrs)
      assert song.artist == "some updated artist"
      assert song.genius_lyrics == "some updated genius_lyrics"
      assert song.songs == []
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Markov.update_song(song, @invalid_attrs)
      assert song == Markov.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Markov.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Markov.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Markov.change_song(song)
    end
  end
end
