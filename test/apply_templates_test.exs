defmodule ApplyTemplatesTest do
  use ExUnit.Case
  alias ElixirStructureManager.Core.ApplyTemplates

  import Mock

  test "should get variable list" do
    project_name = "test_project"
    res = ApplyTemplates.manage_application_name(project_name)
    assert {:ok, _project_name, "TestProject"} = res
  end

  test "should get invalid appliation name" do
    res = ApplyTemplates.manage_application_name("invalidname")
    assert {:error, :invalid_application_name} = res
  end

  test "should get variables list" do
    res = ApplyTemplates.create_variables_list(:test, "test")
    assert {:ok, [
      %{name: "{application_name_atom}", value: :test},
      %{name: "{module_name}", value: "test"}
    ]} = res
  end

  test "should load template file" do
    with_mocks([
      {File, [], [read: fn(_path) -> {:ok, "{\"test\": \"replace content\"}"} end]}
    ]) do
      res = ApplyTemplates.load_template_file("/some_path")
      assert %{test: "replace content"} = res
    end
  end
  
  test "should load template file wit herror" do
    with_mocks([
      {File, [], [read: fn(_path) -> {:err, "error reading file"} end]}
    ]) do
      res = ApplyTemplates.load_template_file("/some_path")
      assert {:err, _err} = res
    end
  end

end
