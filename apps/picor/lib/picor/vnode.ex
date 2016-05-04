defmodule Picor.Vnode do
  @behaviour :riak_core_vnode
  require Logger
  require Record

  Record.defrecord :riak_core_fold_req_v2, Record.extract(:riak_core_fold_req_v2, from_lib: "riak_core/include/riak_core_vnode.hrl")
  Record.defrecord :state, [:partition, :db]

  def start_vnode(partition) do
    #Logger.warn("some stuff from start_vnode? #{inspect([partition, __MODULE__])} and #{inspect(stuff)}")
    :riak_core_vnode_master.get_vnode_pid(partition, __MODULE__)
  end

  def init([partition]) do
    dbh = :ets.new(nil, [])
    {:ok, state(partition: partition, db: dbh)}
  end

  def handle_command(:ping, _sender, state) do
    Logger.warn("got a ping request!! woohoO!'")
    {:reply, {:pong, state(state, :partition)}, state}
  end

  def handle_command({req_id, {:store, key, data}}, _sender, state(db: dbh)=state) do
    Logger.warn("store request for #{inspect key} and #{inspect data}")
    result = :ets.insert(dbh, {key, data})
    {:reply, {req_id, {result}}, state}
  end

  def handle_command({req_id, {:fetch, key}}, _sender, state(db: dbh)=state) do
    Logger.warn("fetch request for #{inspect key}")
    case :ets.lookup(dbh, key) do
      [] ->
        {:reply, {req_id, {:not_found}}, state}
      [{key, data}] ->
        {:reply, {req_id, {key, data}}, state}
    end
  end

  def handle_command(message, _sender, state) do
    Logger.warn("weird command? #{inspect([message, state])}")
    {:reply, {:pong, state(state, :partition)}, state}
  end

  def handle_handoff_command(riak_core_fold_req_v2(foldfun: visit_fun, acc0: acc0)=_fold_req, _sender, state(db: dbh)=state) do
    fold_fn = fn(object, acc_in) ->
      Logger.warn("folding over thing: #{inspect object}")
      acc_out = visit_fun.({:foo_bucket, object}, object, acc_in)
      Logger.warn("what is my acc out? #{inspect acc_out}")
      acc_out
    end
    final = :ets.foldl(fold_fn, acc0, dbh)
    {:reply, final, state}
  end

  def handle_handoff_command(message, _sender, state) do
    Logger.warn("unhandled handoff command: #{inspect(message)}")
    {:noreply, state}
  end

  def handoff_starting(_target_node, state) do
    Logger.warn("starting handoff! #{inspect(state)}")
    {true, state}
  end

  def handoff_cancelled(state) do
    Logger.warn("handoff cancelled :( #{inspect(state)}")
    {:ok, state}
  end

  def handoff_finished(_target_node, state) do
    Logger.warn("handoff finished! #{inspect(state)}")
    {:ok, state}
  end

  def handle_handoff_data(data, state(db: dbh)=state) do
    {bucket, blob} = :erlang.binary_to_term(data)
    {key, value} = blob
    res = :ets.insert(dbh, {key, value})
    Logger.warn("got some handoff data: key: #{ inspect key } and value: #{ inspect value }. inserted it, and #{ inspect res }")
    {:reply, :ok, state}
  end

  def encode_handoff_item(object_name, object_value) do
    Logger.warn("encoding a handoff item#{inspect([object_name, object_value])}")
    :erlang.term_to_binary({object_name, object_value})
  end

  def is_empty(state(db: dbh)=state) do
    Logger.warn("checking for emptiness")
    {:"$end_of_table" === :ets.first(dbh), state}
  end

  def delete(state(db: dbh)=state) do
    Logger.warn("delete the vnode")
    :ets.delete(dbh)
    {:ok, state}
  end

  def handle_coverage(req, key_spaces, sender, state) do
    Logger.warn("handle coverage #{inspect([req, key_spaces, sender, state])}")
    {:stop, :not_implemented, state}
  end

  def handle_exit(pid, reason, state) do
    Logger.warn("handle exit #{inspect([pid, reason, state])}")
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.warn("terminate #{inspect([reason, state])}")
    :ok
  end
end
