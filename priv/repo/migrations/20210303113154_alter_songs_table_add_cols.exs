defmodule Lyricsmashup.Repo.Migrations.AlterSongsTableAddCols do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      add :num_likes, :integer
      add :img_url, :string
    end
  end
end
