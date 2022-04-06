defmodule GenerateConfig do
  require Logger

  def load_template_file(read_path) do
    with {:ok, content} <- File.read(read_path),
         {:ok, parsed} <- Poison.decode(content),
         normalized <- normalize(parsed) do
      normalized
    else
      err ->
        Logger.error("Error loading consumers #{inspect(err)}")
        err
    end
  end

  def create_content(path) do
    Logger.info("Creating directory #{inspect(path)}")
    File.mkdir_p(Path.dirname(path)) |> IO.inspect()
  end

  defp normalize(%{__struct__: _} = value), do: value

  defp normalize(%{} = map) do
    Map.to_list(map)
    |> Enum.map(fn {key, value} -> {String.to_atom(key), normalize(value)} end)
    |> Enum.into(%{})
  end

  defp normalize(value) when is_list(value), do: Enum.map(value, &normalize/1)
  defp normalize(value), do: value

end
