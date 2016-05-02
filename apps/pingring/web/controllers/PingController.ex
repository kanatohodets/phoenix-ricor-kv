defmodule Pingring.PingController do
  use Phoenix.Controller
  use Pingring.Web, :controller

  def ping(conn, _params) do
    pong = Picor.Service.ping |> Tuple.to_list
    {:ok, json} = Poison.encode(pong)
    Plug.Conn.send_resp(conn, 200, json)
  end

end
