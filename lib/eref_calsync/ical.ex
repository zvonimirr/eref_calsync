defmodule ErefCalsync.Ical do
  alias ErefCalsync.Repo

  @output_path Application.compile_env!(:eref_calsync, :ics_output_path)

  def create_calendar do
    events =
      Repo.all(ErefCalsync.Class)
      |> Enum.map(&transform_event/1)

    ics = ICalendar.to_ics(%ICalendar{events: events})
    File.write!(@output_path, ics)
  end

  def clear_calendar do
    File.rm!(@output_path)
  end

  defp transform_event(%ErefCalsync.Class{} = class) do
    {dtstart, dtend} = ErefCalsync.Class.get_datetime_from_class(class)

    %ICalendar.Event{
      summary: class.name,
      description: "#{class.teacher} - #{class.room}",
      location: class.room,
      rrule: %{
        freq: "WEEKLY"
      },
      dtstart: dtstart,
      dtend: dtend
    }
  end
end
