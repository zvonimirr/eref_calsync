defmodule ErefCalsync.Repo.Migrations.UniqueGID do
  use Ecto.Migration

  def change do
    create(unique_index(:classes, [:google_calendar_id]))
  end
end
