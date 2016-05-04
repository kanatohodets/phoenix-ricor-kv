defmodule Picor.OpFSM.Sup do
  use Supervisor

  def start_op_fsm(args) do
    Supervisor.start_child(__MODULE__, args)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Picor.OpFSM, [], restart: :temporary),
    ]
    supervise(children, strategy: :simple_one_for_one, max_restarts: 10, max_seconds: 10)
  end
end
