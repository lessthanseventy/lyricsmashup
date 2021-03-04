defmodule Lyricsmashup.Repo.Migrations.AlterSongsTable do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      remove :artist
      remove :genius_lyrics
      remove :songs
      add :title, :string
      add :lyrics, :string
    end
  end
end
