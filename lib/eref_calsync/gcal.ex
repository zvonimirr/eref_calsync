defmodule ErefCalsync.Gcal do
  alias ErefCalsync.Repo
  alias GoogleApi.Calendar.V3.Connection
  alias GoogleApi.Calendar.V3.Api
  import Ecto.Query

  @calendar_id Application.compile_env!(:eref_calsync, :calendar_id)

  def create_calendar do
    Repo.all(from(c in ErefCalsync.Class, where: is_nil(c.google_calendar_id)))
    |> Enum.map(&create_event/1)
    |> Enum.map(fn event ->
      id = event.db_id
      class = Repo.get!(ErefCalsync.Class, id)

      ErefCalsync.Class.changeset(class, %{google_calendar_id: event.id})
      |> Repo.update!()
    end)
  end

  def clear_calendar do
    Repo.all(from(c in ErefCalsync.Class, where: not is_nil(c.google_calendar_id)))
    |> Enum.map(fn class ->
      Api.Events.calendar_events_delete(connect(), @calendar_id, class.google_calendar_id)
      Repo.delete!(class)
    end)
  end

  defp connect do
    Goth.fetch!(ErefCalsync.Goth)
    |> Map.get(:token)
    |> Connection.new()
  end

  defp create_event(%ErefCalsync.Class{} = class) do
    body =
      %{
        summary: class.name,
        description: '#{class.teacher} - #{class.room}',
        location: class.room
      }
      |> Map.merge(get_datetime_from_class(class))

    {:ok, event} = Api.Events.calendar_events_insert(connect(), @calendar_id, body: body)

    event
    |> Map.merge(%{db_id: class.id})
  end

  defp get_datetime_from_class(%ErefCalsync.Class{} = class) do
    # class.day maps to day of week
    # class.start_time maps to start time
    # class.end_time maps to end time

    # From current time skip to the first day of the week
    now = DateTime.now!("Europe/Berlin")
    # Keep increasing the day until we reach the day of the week
    # of the class
    day =
      Enum.reduce_while(0..6, now, fn _i, acc ->
        if Date.day_of_week(acc) == class.day + 1 do
          {:halt, acc}
        else
          {:cont, DateTime.add(acc, 1, :day)}
        end
      end)

    # Add the start time to the day
    start_time =
      day
      |> DateTime.to_date()
      |> DateTime.new!(class.start_time, "Europe/Berlin")
      |> DateTime.to_iso8601()

    # Add the end time to the day
    end_time =
      day
      |> DateTime.to_date()
      |> DateTime.new!(class.end_time, "Europe/Berlin")
      |> DateTime.to_iso8601()

    %{
      start: %{
        dateTime: start_time,
        timeZone: "Europe/Berlin"
      },
      end: %{
        dateTime: end_time,
        timeZone: "Europe/Berlin"
      }
    }
  end
end
