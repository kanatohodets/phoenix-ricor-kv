use Mix.Config

config :riak_core,
  node: 'dev_b@192.168.1.13',
  web_port: 8198,
  handoff_port: 8199,
  ring_state_dir: 'ring_data_dir_b',
  platform_data_dir: 'data_b',
  # TODO: wtf...
  schema_dirs: ['/Users/btyler/personal/prog/elixir/phicor/_build/dev_b/lib/riak_core/priv']
