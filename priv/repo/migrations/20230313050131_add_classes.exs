defmodule ErefCalsync.Repo.Migrations.AddClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add(:name, :string)
      add(:teacher, :string)

      add(:day, :integer)
      add(:start_time, :time)
      add(:end_time, :time)

      add(:room, :string)
      add(:enrolled, :boolean)

      add(:google_calendar_id, :string, null: true, default: nil)
    end
  end
end
