import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :phx_proj, PhxProjWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json", url: [host: "*", port: 80], secret_key_base: System.get_env("SECRET_KEY_BASE"), server: true, code_reloader: false, check_origin: false, watchers: []

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: PhxProj.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

config :phx_proj, PhxProj.Repo,
  username: System.get_env("DB_USERANME"),
  password: System.get_env("DB_PASS"),
  hostname: System.get_env("DB_HOST"),
  stacktrace: true,
  database: System.get_env("DB_NAME"),
  sslmode: "required",
  port: System.get_env("DB_PORT"),
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

#S1e2y3i4@1029
  # config :my_app, MyAppWeb.Endpoint,
  # url: [host: "example.com", port: 80],

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :phx_proj, PhxProjWeb.Repo, migration_primary_key: [name: :id, type: :binary_id]
