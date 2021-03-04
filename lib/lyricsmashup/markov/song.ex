defmodule Lyricsmashup.Markov.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :title, :string
    field :lyrics, :string
    field :num_likes, :integer, default: 0
    field :img_url, :string

    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:title, :lyrics, :img_url])
  end
end
