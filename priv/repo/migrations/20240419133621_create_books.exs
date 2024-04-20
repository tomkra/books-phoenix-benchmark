defmodule Bench.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :year_published, :integer
      add :isbn, :string
      add :price, :decimal
      add :available, :boolean, default: false, null: false
      add :author_id, references(:authors, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:books, [:author_id])
    create index(:books, [:title])
    create index(:books, [:author_id, :title], unique: true)
  end
end
