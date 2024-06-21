defmodule Sectory.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SectoryWeb.Telemetry,
      Sectory.Repo,
      {DNSCluster, query: Application.get_env(:sectory, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sectory.PubSub},
      # Start a worker by calling: Sectory.Worker.start_link(arg)
      # {Sectory.Worker, arg},
      # Start to serve requests, typically the last entry
      SectoryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sectory.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SectoryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
