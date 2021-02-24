defmodule Lyricsmarkov.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :num_likes, :integer, default: 0
    field :num_shares, :integer, default: 0

    field :username, :string, default: "andrew"

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 250)
  end
end
