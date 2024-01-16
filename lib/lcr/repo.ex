defmodule Lcr.Repo do
  use Ecto.Repo,
    otp_app: :lcr,
    adapter: Ecto.Adapters.Postgres
end
