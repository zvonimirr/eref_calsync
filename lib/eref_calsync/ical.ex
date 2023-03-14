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
    %ICalendar.Event{
      summary: class.name,
      description: "#{class.teacher} - #{class.room}",
      location: class.room,
      rrule: %{
        freq: "WEEKLY"
      }
    }
    |> Map.merge(get_datetime_from_class(class))
  end

  defp get_datetime_from_class(%ErefCalsync.Class{} = class) do
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

    %{
      dtstart: start_time,
      dtend: end_time
    }
  end
end
