defmodule ErefCalsync.Class.Transformer do
  def transform(%{classes: classes, times: times}) do
    classes
    |> Enum.map(&Enum.with_index/1)
    |> Enum.map(
      &Enum.map(&1, fn {class, index} ->
        case class do
          :no_class -> class
          _class -> transform_class({class, index, times})
        end
      end)
    )
    |> Enum.with_index()
    |> Enum.map(fn {classes, index} ->
      classes
      |> Enum.map(fn class ->
        if is_map(class), do: Map.put_new(class, :day, index), else: class
      end)
    end)
  end

  defp transform_class({class, index, times}) do
    times = times |> Enum.at(index)

    class
    |> Map.put_new(:start_time, List.first(times))
    |> Map.put_new(:end_time, List.last(times))
    # TODO: Figure out how to ask for this properly
    |> Map.put_new(:enrolled, true)
  end
end
