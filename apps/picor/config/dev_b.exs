use Mix.Config

config :riak_core,
  node: 'dev_b@127.0.0.1',
  web_port: 8198,
  handoff_port: 8199,
  ring_state_dir: 'ring_data_dir_b',
  platform_data_dir: 'data_b',
  schema_dirs: ['priv']
