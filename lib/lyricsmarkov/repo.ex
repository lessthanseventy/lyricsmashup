defmodule Lyricsmarkov.Repo do
  use Ecto.Repo,
    otp_app: :lyricsmarkov,
    adapter: Ecto.Adapters.Postgres
end
