defmodule PhxProj.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhxProjWeb.Telemetry,
      PhxProj.Repo,
      {DNSCluster, query: Application.get_env(:phx_proj, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhxProj.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhxProj.Finch},
      # Start a worker by calling: PhxProj.Worker.start_link(arg)
      # {PhxProj.Worker, arg},
      # Start to serve requests, typically the last entry
      PhxProjWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxProj.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxProjWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
