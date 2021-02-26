defmodule Gaslight.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :username, :string
      add :body, :text
      add :num_likes, :integer
      add :num_shares, :integer

      timestamps()
    end

  end
end
