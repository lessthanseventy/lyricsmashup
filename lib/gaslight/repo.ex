defmodule Gaslight.Repo do
  use Ecto.Repo,
    otp_app: :gaslight,
    adapter: Ecto.Adapters.Postgres
end
