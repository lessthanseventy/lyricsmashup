defmodule Gaslight.Markov.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :artist, :string
    field :genius_lyrics, :string
    field :songs, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:artist, :genius_lyrics, :songs])
    |> validate_required([:artist, :genius_lyrics, :songs])
  end
end
