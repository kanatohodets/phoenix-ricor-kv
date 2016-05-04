defmodule Pingring.StoreController do
  require Logger
  use Phoenix.Controller
  use Pingring.Web, :controller

  def store(%Plug.Conn{body_params: data}=conn, %{"key" => key}=params) do
    n = case params["n"] do
      nil -> 3
      n -> n
    end

    Logger.info("storing stuff: #{inspect conn}")
    result = Picor.Service.store(key, data, n)
    Logger.info("storing stuff: stored! #{inspect result}")
    render conn, store: result
  end

  def fetch(conn, %{"key" => key}=params) do
    n = case params["n"] do
      nil -> 1
      n -> String.to_integer(n)
    end

    case Picor.Service.fetch(key, n) do
      [] ->
        render conn, fetch: :not_found

      data ->
        cleaned = for {key, value} <- data, do: %{key => value}
        render conn, fetch: cleaned

    end
  end

end
