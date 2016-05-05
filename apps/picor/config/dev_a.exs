use Mix.Config

config :riak_core,
  node: 'dev_a@127.0.0.1',
  web_port: 8098,
  handoff_port: 8099,
  ring_state_dir: 'ring_data_dir_a',
  platform_data_dir: 'data_a',
  schema_dirs: ['priv']
