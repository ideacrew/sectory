defmodule Sectory.Sbom.Component do
  require Lens.Macros

  def main_component_name(analysis) do
    Lens.one!(main_component_lens(), analysis)
    |> component_name()
  end

  def main_component_version(analysis) do
    Lens.one!(main_component_lens(), analysis)
    |> component_version()
  end

  def component_name(component) do
    name_lens()
    |> Lens.either(Lens.const("NO COMPONENT NAME"))
    |> Lens.one!(component)
  end

  def component_version(component) do
    version_lens()
    |> Lens.to_list(component)
    |> Enum.at(0, "UNSPECIFIED")
  end

  Lens.Macros.deflensp main_component_lens() do
    Lens.key?("metadata")
    |> Lens.key?("component")
  end

  Lens.Macros.deflensp name_lens() do
    Lens.key?("name")
  end

  Lens.Macros.deflensp version_lens() do
    Lens.key?("version")
    |> Lens.either(git_sha_lens())
  end

  Lens.Macros.deflensp git_sha_lens() do
    Lens.key?("hashes")
    |> Lens.all()
    |> Lens.filter(fn(v) when is_map(v) ->
      v["alg"] == "SHA-1"
    end)
    |> Lens.key?("content")
  end
end
