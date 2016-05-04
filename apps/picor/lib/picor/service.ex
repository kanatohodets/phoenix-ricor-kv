defmodule Picor.Service do
  require Record
  require Logger
  Record.extract_all(from_lib: "riak_core/include/riak_core_vnode.hrl")
  def ping do
    doc_idx = :riak_core_util.chash_key({"ping", :erlang.term_to_binary(:os.timestamp())})
    pref_list = :riak_core_apl.get_primary_apl(doc_idx, 1, Picor.Service)
    Logger.warn("pref list: #{inspect(pref_list)}")
    [{index_node, _type}] = pref_list
    # riak core appends "_master" to Picor.Vnode.
    :riak_core_vnode_master.sync_spawn_command(index_node, :ping, Picor.Vnode_master)
  end

  def store(key, data, n) when n > 1 do
    w = n - 1
    do_store(key, data, n, w)
  end

  def store(key, data, 1=n) do
    w = n
    do_store(key, data, n, w)
  end

  def fetch(key, n) when n > 1 do
    w = n - 1
    do_fetch(key, n, w)
  end

  def fetch(key, 1=n) do
    w = n
    do_fetch(key, n, w)
  end

  defp do_store(key, data, n, w) do
    {:ok, req_id} = Picor.OpFSM.op(key, {:store, key, data}, n, w)
    wait_for_reqid(req_id, 5000)
  end

  defp do_fetch(key, n, w) do
    {:ok, req_id} = Picor.OpFSM.op(key, {:fetch, key}, n, w)
    {:ok, responses} = wait_for_reqid(req_id, 5000)
    Enum.filter(responses, fn(x) -> x != {:not_found} end)
  end

  defp wait_for_reqid(req_id, timeout) do
    receive do
      {^req_id, value} ->
        {:ok, value}
    after
      timeout ->
        {:error, :timeout}
    end
  end

end
