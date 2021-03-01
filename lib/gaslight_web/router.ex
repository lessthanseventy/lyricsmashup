defmodule GaslightWeb.Router do
  use GaslightWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GaslightWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GaslightWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Index, :new
    live "/posts/:id/edit", PostLive.Index, :edit

    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/show/edit", PostLive.Show, :edit

    live "/songs/new", SongLive.Index, :index
    live "/songs/list", SongLive.Index, :list
    live "/songs/:id/edit", SongLive.Index, :edit

    live "/songs/:id", SongLive.Show, :show
    live "/songs/:id/show/edit", SongLive.Show, :edit
end

  # Other scopes may use custom stacks.
  # scope "/api", GaslightWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: GaslightWeb.Telemetry
    end
  end
end
