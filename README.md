# ErefCalsync
![https://i.imgur.com/eMhUj6J.png](https://i.imgur.com/eMhUj6J.png)
## Requirements
- [Elixir](https://elixir-lang.org/)

## Google Setup

1. Follow [this guide](https://support.google.com/a/answer/7378726?hl=en) to get a JSON file containing your service account data.
2. Create a new calendar or use an existing one.
3. Add your service account as an owner of that calendar (i.e. allow them to alter events)

## App Setup
1. Create `config/secret.exs`:
	```elixir
    import Config

    config :eref_calsync,
      calendar_id:
        "<YOUR CALENDAR ID>"
    ```
2. Run `mix deps.get`
3. Run `mix ecto.create`
4. Run `mix ecto.migrate`
5. Run the app with `GOOGLE_APPLICATION_CREDENTIALS=<path to json> iex -S mix`
6. Fetch the classes:
```elixir
classes = ErefCalsync.Class.Crawler.get_classes_from_url("<URL (i.e. https://eref.vts.su.ac.rs/sr/default/schedule/groupschedule/id/643/school_year/18>")
```
7. Transform them to proper data:
```elixir
transformed = ErefCalsync.Class.Transformer.transform(classes)
```
8. Insert them into the DB:
```elixir
ErefCalsync.Class.Sync.from_transformed_data(transformed)
```
9. Push them to the calendar:
```elixir
ErefCalsync.Gcal.create_calendar()
```

## Cleaning the calendar
```elixir
ErefCalsync.Gcal.clear_calendar()
```

## Notes
Currently everything from the table is pushed. If you want to avoid this, you can delete it from the DB manually.

If you change the `enrolled` to false in the DB the class will still show up but with a different color.
