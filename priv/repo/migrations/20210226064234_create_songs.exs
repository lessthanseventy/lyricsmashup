defmodule Lyricsmashup.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :artist, :string
      add :genius_lyrics, :text
      add :songs, {:array, :string}

      timestamps()
    end

  end
end
