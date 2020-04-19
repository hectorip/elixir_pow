defmodule ProofOfWorkWeb.Router do
  use ProofOfWorkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProofOfWorkWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ProofOfWorkWeb do
    pipe_through :api

    get "/proof/:diff", PageController, :proof
    get "/proof_parallel/:diff", PageController, :proof_parallel
    get "/proof/:diff/:q", PageController, :proof

  end
end
