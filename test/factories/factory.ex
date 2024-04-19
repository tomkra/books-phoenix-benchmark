defmodule MyApp.Factory do
  use ExMachina.Ecto, repo: Bench.Repo

  # Define your factories in /test/factories and declare it here,
  use Bechn.AuthorFactory
end
