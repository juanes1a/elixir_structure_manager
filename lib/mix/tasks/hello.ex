defmodule Hello do

  alias ElixirStructureManager.Core.ApplyTemplates
  require Logger

  @structure_path "./lib/create_structure/parameters/create_structure.json"

  def run(application_name) do
    with {:ok, atom_name, module_name} <- ApplyTemplates.manage_application_name(application_name),
         template <- ApplyTemplates.load_template_file(@structure_path),
         {:ok, variable_list} <- ApplyTemplates.create_variables_list(atom_name, module_name) do
      ApplyTemplates.create_folder(template, variable_list)
    else
      error -> Logger.error("Ocurrio un error creando la estructura: #{inspect(error)}")
    end
  end
end
