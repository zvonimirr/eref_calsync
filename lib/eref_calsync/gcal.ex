defmodule ErefCalsync.Gcal do
  alias ErefCalsync.Repo
  alias GoogleApi.Calendar.V3.Connection
  alias GoogleApi.Calendar.V3.Api
  import Ecto.Query

  @calendar_id Application.compile_env!(:eref_calsync, :calendar_id)
  @color_gray 8
  @color_tomato 11

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

      ErefCalsync.Class.changeset(class, %{google_calendar_id: nil})
      |> Repo.update!()
    end)
  end

  defp connect do
    Goth.fetch!(ErefCalsync.Goth)
    |> Map.get(:token)
    |> Connection.new()
  end

  defp create_event(%ErefCalsync.Class{} = class) do
    colorId = if class.enrolled, do: @color_gray, else: @color_tomato
    {dtstart, dtend} = ErefCalsync.Class.get_datetime_from_class(class)

    startdt = %{
      dateTime: dtstart |> Timex.to_datetime() |> DateTime.to_iso8601(),
      timeZone: "Europe/Berlin"
    }

    enddt = %{
      dateTime: dtend |> Timex.to_datetime() |> DateTime.to_iso8601(),
      timeZone: "Europe/Berlin"
    }

    body = %{
      summary: class.name,
      description: "#{class.teacher} - #{class.room}",
      location: class.room,
      colorId: colorId,
      recurrence: [
        "RRULE:FREQ=WEEKLY"
      ],
      start: startdt,
      end: enddt
    }

    {:ok, event} = Api.Events.calendar_events_insert(connect(), @calendar_id, body: body)

    event
    |> Map.merge(%{db_id: class.id})
  end
end
