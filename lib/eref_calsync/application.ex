defmodule ErefCalsync.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # TODO: Show a proper error message if the GOOGLE_APPLICATION_CREDENTIALS
    # environment variable is not set.
    credentials =
      System.fetch_env!("GOOGLE_APPLICATION_CREDENTIALS")
      |> File.read!()
      |> Jason.decode!()

    source = {:service_account, credentials}

    children = [
      ErefCalsync.Repo,
      {Goth, name: ErefCalsync.Goth, source: source}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ErefCalsync.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
