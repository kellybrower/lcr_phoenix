defmodule Lcr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LcrWeb.Telemetry,
      Lcr.Repo,
      {DNSCluster, query: Application.get_env(:lcr, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lcr.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Lcr.Finch},
      # Start a worker by calling: Lcr.Worker.start_link(arg)
      # {Lcr.Worker, arg},
      # Start to serve requests, typically the last entry
      LcrWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lcr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LcrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
