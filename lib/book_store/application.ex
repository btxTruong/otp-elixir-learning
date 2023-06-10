defmodule BookStore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BookStoreWeb.Telemetry,
      # Start the Ecto repository
      BookStore.Repo,
      {Phoenix.PubSub, name: BookStore.PubSub},
      {Finch, name: BookStore.Finch},
      BookStore.BookRegistry.child_spec(),
      BookStore.BookDynamicSupervisor,
      BookStore.BookStateHydrator,
      BookStoreWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BookStore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BookStoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
