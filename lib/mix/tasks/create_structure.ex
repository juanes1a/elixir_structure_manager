defmodule Mix.Tasks.CreateStructure do

  @moduledoc """
  Creates a new Clean architecture scaffold

      $ mix create_structure [application_name]
  """

  alias ElixirStructureManager.Core.ApplyTemplates
  require Logger

  use Mix.Task

  @structure_path "./lib/create_structure/parameters/create_structure.json"
  @version Mix.Project.config()[:version]

  def run ([]) do
    Mix.Tasks.Help.run(["create_structure"])
  end

  def run([version]) when version in ~w(-v --version) do
    IO.puts "Scaffold version #{@version}"
  end

  @shortdoc "Creates a new clean architecture application."
  def run([application_name]) do

    IO.inspect(application_name)

    Mix.Task.run("app.start")

    with {:ok, atom_name, module_name} <- ApplyTemplates.manage_application_name(application_name),
         template <- ApplyTemplates.load_template_file(@structure_path),
         {:ok, variable_list} <- ApplyTemplates.create_variables_list(atom_name, module_name) do
      ApplyTemplates.create_folder(template, variable_list)
    else
      error -> Logger.error("Ocurrio un error creando la estructura: #{inspect(error)}")
    end
  end
end
