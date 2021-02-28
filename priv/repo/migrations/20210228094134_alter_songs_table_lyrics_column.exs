defmodule Gaslight.Repo.Migrations.AlterSongsTableLyricsColumn do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      modify :lyrics, :text
    end
  end
end
