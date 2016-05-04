defmodule Pingring.Router do
  use Pingring.Web, :router

  pipeline :api do
    plug :accepts, ["json", "txt"]
  end

  scope "/api", Pingring do
    pipe_through :api
    get "/ping", PingController, :ping
    put "/store/:key", StoreController, :store
    get "/store/:key", StoreController, :fetch
  end
end
