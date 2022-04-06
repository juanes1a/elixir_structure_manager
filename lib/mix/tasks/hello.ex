defmodule Hello do

  alias GenerateConfig
  require Logger

  def run(application_name) do
    structure_path = "./lib/create_structure/parameters/create_structure.json"
    template = GenerateConfig.load_template_file(structure_path)
    cretate_folder(template, application_name)
  end

  def cretate_folder([], _) do
    Logger.info("Creación de la estructura terminada")
  end

  def cretate_folder([%{folder: folder, path: path, files: []} | tail], _) do
    GenerateConfig.create_content(path)
  end

  def cretate_folder([%{folder: folder, path: path, files: files} | tail], application_name) do
    create_files(files, path, application_name)
    #cretate_folder(tail)
  end

  def create_files([], folder_path, _application_name) do
    Logger.info("Archivos del directorio #{folder_path} creados")
  end

  def create_files([head | tail], folder_path, application_name) do
    IO.inspect(application_name)
    %{name: name, template_path: template_path, module_name: module_name} = head
    file = folder_path <> "/" <> name
    GenerateConfig.create_content(file)

    {:ok, content} = File.read(template_path)
    new_content = String.replace(content, "{application_name_atom}", application_name)
    File.write(file, new_content)

    create_files(tail, folder_path, application_name)

  end




end
