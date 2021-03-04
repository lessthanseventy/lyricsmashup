defmodule Lyricsmashup.Repo do
  use Ecto.Repo,
    otp_app: :lyricsmashup,
    adapter: Ecto.Adapters.Postgres
end
