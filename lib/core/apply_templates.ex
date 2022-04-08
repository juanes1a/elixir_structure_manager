defmodule ElixirStructureManager.Core.ApplyTemplates do

  alias ElixirStructureManager.Core.DataTypeUtils
  require Logger

  def create_variables_list(atom_name, module_name) do
    {
      :ok,
      [
        %{name: "{application_name_atom}", value: atom_name},
        %{name: "{module_name}", value: module_name}
      ]
    }
  end

  def cretate_folder([], _variable_list) do
    Logger.info("Creación de la estructura terminada")
  end
  def cretate_folder([%{folder: folder, path: path, files: []} | tail], variable_list) do
    Logger.info("Creando directorio vacio #{folder}")
    create_content(path)
    cretate_folder(tail, variable_list)
  end
  def cretate_folder([%{folder: folder, path: path, files: files} | tail], variable_list) do
    Logger.info("Creando directorio #{folder}")
    create_files(files, path, variable_list)
    cretate_folder(tail, variable_list)
  end

  defp create_files([], folder_path, _variable_list) do
    Logger.info("Archivos del directorio #{folder_path} creados")
  end
  defp create_files([head | tail], folder_path, variable_list) do
    %{name: name, template_path: template_path} = head
    with file_full_path <- folder_path <> "/" <> name,
         :ok <- create_content(file_full_path),
         {:ok, file_content} <- File.read(template_path),
         full_file_content <- replace_variables(variable_list, file_content),
         :ok <- File.write(file_full_path, full_file_content) do
      create_files(tail, folder_path, variable_list)
    end
  end

  defp replace_variables([], content) do
    Logger.info("Se reemplazaron las variables")
    content
  end
  defp replace_variables([%{name: variable_name, value: value} | tail], content) do
    replace_variables(tail, String.replace(content, variable_name, value))
  end

  def manage_application_name(application_name) do
    case String.match?(application_name, ~r/^([a-zA-Z0-9]+_[a-zA-Z0-9]+){1,}$/) do
      true ->
        {
          :ok,
          application_name
          |> String.downcase(),
          application_name
          |> String.downcase()
          |> String.split("_")
          |> Enum.map(&up_case_first/1)
          |> Enum.join()
        }
      _ ->
        Logger.error("Nombre de aplicación invalido")
        {:error, :invalid_application_name}
    end
  end

  defp up_case_first(<<first :: utf8, rest :: binary>>), do: String.upcase(<<first :: utf8>>) <> rest

  def load_template_file(read_path) do
    with {:ok, content} <- File.read(read_path),
         {:ok, parsed} <- Poison.decode(content),
         normalized <- DataTypeUtils.normalize(parsed) do
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
end
