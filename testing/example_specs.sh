cd examples/example_app

echo "
use Mix.config
config :example_app, ExampleApp.Repo,
  username: \"postgres\",
  password: \"\"
" > config/secrets.exs

mix deps.get
mix do ecto.create, ecto.migrate
mix espec
