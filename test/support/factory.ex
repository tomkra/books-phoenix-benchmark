defmodule Bench.Factory do
  use ExMachina.Ecto, repo: Bench.Repo

  use Bench.AuthorFactory
end
