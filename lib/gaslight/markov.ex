defmodule Gaslight.Markov do
  @moduledoc """
  The Markov context.
  """

  import Ecto.Query, warn: false
  alias Gaslight.Repo

  alias Gaslight.Markov.Song

  @doc """
  Returns the list of songs.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs do
    Repo.all(from s in Song, order_by: [desc: s.id])
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id), do: Repo.get!(Song, id)

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:song_created)
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
    |> broadcast(:song_updated)
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## songs

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  def inc_likes(%Song{id: id}) do
    {1, [song]} =
      from(s in Song, where: s.id == ^id, select: s)
    |> Repo.update_all(inc: [num_likes: 1])

    broadcast({:ok, song}, :song_updated)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Gaslight.PubSub, "songs")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, song}, event) do
    Phoenix.PubSub.broadcast(Gaslight.PubSub, "songs", {event, song})
    {:ok, song}
  end
end
