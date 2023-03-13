defmodule ErefCalsync.Class do
  use Ecto.Schema

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
end
