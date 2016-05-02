defmodule Picor.App do
  use Application
  require Logger

  def start(_type, _args) do
    case Picor.Sup.start_link() do
      {:ok, pid} ->
        :ok = :riak_core.register([{:vnode_module, Picor.Vnode}])

        Logger.warn("Picor.Service pid is #{inspect(self())}, and my supervisor is #{inspect(pid)}")
        :ok = :riak_core_node_watcher.service_up(Picor.Service, self())
        {:ok, pid}
      {:error, reason} ->
        Logger.error("omg error while starting app: #{inspect(reason)}")
        {:error, reason}
    end
  end
end


