defmodule ErefCalsync.Class.Crawler do
  def get_classes_from_url(url) when is_binary(url) do
    with {:ok, response} <- HTTPoison.get(url),
         {:ok, html} <- Floki.parse_document(response.body),
         [table | _rest] <- Floki.find(html, "table.schedule"),
         [times | classes] <- table |> Tuple.delete_at(0) |> Tuple.delete_at(0) |> Kernel.elem(0) do
      %{
        times: extract_class_times(times),
        classes: Enum.map(classes, &extract_class_info/1)
      }
    end
  end

  def get_classes_from_url(_url), do: []

  defp extract_class_times({"tr", [], times}) do
    times
    |> Enum.filter(fn {tag_name, _attrs, _content} -> tag_name != "td" end)
    |> Enum.map(fn {_tag_name, _attrs, [_class_meta, class_el]} -> class_el end)
    |> Enum.map(fn {_tag_name, _attrs, [class_time]} -> class_time end)
    |> Enum.map(&String.split(&1, " - "))
    |> Enum.map(&Enum.map(&1, fn time -> String.replace(time, "h", "") end))
  end

  defp extract_class_info({"tr", _attrs, classes}) do
    # Drop the first element because it's the day of the week
    classes
    |> Enum.drop(1)
    # Colspan takes up multiple columns, so we need to duplicate the class
    |> Enum.map(fn
      {"td", [{"colspan", colspan}], class_el} ->
        List.duplicate(class_el, String.to_integer(colspan))

      {"td", _attrs, class_el} ->
        [class_el]
    end)
    |> Enum.map(fn class_slot ->
      case class_slot do
        [[{"div", [], []}]] -> :no_class
        class_info -> extract_class_meta(class_info)
      end
    end)
    |> List.flatten()
  end

  defp extract_class_meta(class_group) when is_list(class_group) do
    Enum.map(class_group, fn [name_el, teacher_el, place_el] ->
      %{
        name: Floki.text(name_el),
        teacher: Floki.text(teacher_el),
        room: Floki.text(place_el)
      }
    end)
  end
end
