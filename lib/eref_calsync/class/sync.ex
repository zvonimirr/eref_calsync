defmodule ErefCalsync.Class.Sync do
  alias ErefCalsync.Repo
  alias ErefCalsync.Class

  def from_transformed_data(data) do
    data
    |> List.flatten()
    |> Enum.map(&add_class/1)
  end

  def add_class(:no_class), do: {:ok, :no_class}

  def add_class(class) do
    Class.changeset(%Class{}, class)
    |> Repo.insert()
  end

  def clear_all do
    Repo.delete_all(Class)
  end
end
