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

  def get_datetime_from_class(%__MODULE__{} = class) do
    now = Timex.now("Europe/Berlin")

    day =
      Enum.reduce_while(0..6, now, fn _i, acc ->
        if Date.day_of_week(acc) == class.day + 1 do
          {:halt, acc}
        else
          {:cont, Timex.shift(acc, days: 1)}
        end
      end)

    start_time = Timex.set(day, hour: class.start_time.hour, minute: class.start_time.minute)

    end_time = Timex.set(day, hour: class.end_time.hour, minute: class.end_time.minute)

    {start_time, end_time}
  end
end
