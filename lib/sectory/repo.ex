defmodule Sectory.Repo do
  use Ecto.Repo,
    otp_app: :sectory,
    adapter: Ecto.Adapters.Postgres
end
