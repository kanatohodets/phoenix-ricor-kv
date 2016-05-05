use Mix.Config

config :riak_core,
  node: 'dev_c@127.0.0.1',
  web_port: 8298,
  handoff_port: 8299,
  ring_state_dir: 'ring_data_dir_c',
  platform_data_dir: 'data_c',
  schema_dirs: ['priv']
