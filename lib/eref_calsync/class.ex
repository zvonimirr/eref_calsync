defmodule ErefCalsync.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field(:name, :string)
    field(:teacher, :string)

    field(:day, :integer)
    field(:start_time, :time)
    field(:end_time, :time)

    field(:room, :string)
    field(:enrolled, :boolean)

    field(:google_calendar_id, :string, default: nil)
  end

  def changeset(class, params \\ %{}) do
    class
    |> cast(params, [
      :name,
      :teacher,
      :day,
      :start_time,
      :end_time,
      :room,
      :enrolled,
      :google_calendar_id
    ])
    |> validate_required([:name, :teacher, :day, :start_time, :end_time, :room, :enrolled])
    |> unique_constraint(:google_calendar_id)
  end
end
