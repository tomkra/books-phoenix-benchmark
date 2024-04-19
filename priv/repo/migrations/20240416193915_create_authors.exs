defmodule Bench.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string
      add :birth, :date
      add :death, :date
      add :books_count, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:authors, [:name])
  end
end
