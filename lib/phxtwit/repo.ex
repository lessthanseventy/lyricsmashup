defmodule Phxtwit.Repo do
  use Ecto.Repo,
    otp_app: :phxtwit,
    adapter: Ecto.Adapters.Postgres
end
