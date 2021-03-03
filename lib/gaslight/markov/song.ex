defmodule Gaslight.Markov.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :title, :string
    field :lyrics, :string
    field :num_likes, :integer, default: 0
    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:title, :lyrics])
  end
end
