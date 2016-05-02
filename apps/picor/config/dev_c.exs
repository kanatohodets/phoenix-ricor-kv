use Mix.Config

config :riak_core,
  node: 'dev_c@192.168.1.13',
  web_port: 8298,
  handoff_port: 8299,
  ring_state_dir: 'ring_data_dir_c',
  platform_data_dir: 'data_c',
  # TODO: wtf...
  schema_dirs: ['/Users/btyler/personal/prog/elixir/phicor/_build/dev_c/lib/riak_core/priv']
