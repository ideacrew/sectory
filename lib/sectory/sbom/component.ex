defmodule Sectory.Sbom.Component do
  @moduledoc """
  Extract data from an SBOM Component structure.
  """

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

  def component_purl(component) do
    Lens.key?("purl")
    |> Lens.either(Lens.const(nil))
    |> Lens.one!(component)
  end

  def component_cpe(component) do
    Lens.key?("cpe")
    |> Lens.either(Lens.const(nil))
    |> Lens.one!(component)
  end

  def component_description(component) do
    Lens.key?("description")
    |> Lens.either(Lens.const(nil))
    |> Lens.one!(component)
  end

  def component_kind(component) do
    case component_purl(component) do
      nil -> "other"
      a -> select_component_kind(a)
    end
  end

  defp select_component_kind(purl) do
    with :no_match <- is_component_kind(purl, "pkg:gem/", "Gem"),
         :no_match <- is_component_kind(purl, "pkg:npm/", "NPM"),
         :no_match <- is_component_kind(purl, "pkg:deb/", "Debian"),
         :no_match <- is_component_kind(purl, "pkg:apk/", "Alpine"),
         :no_match <- is_component_kind(purl, "pkg:alpine/", "Alpine"),
         :no_match <- is_component_kind(purl, "pkg:hex/", "Hex"),
         :no_match <- is_component_kind(purl, "pkg:rpm/", "RPM"),
         :no_match <- is_component_kind(purl, "pkg:maven/", "Maven"),
         :no_match <- is_component_kind(purl, "pkg:github/", "Github") do
      "other"
    end
  end

  defp is_component_kind(purl, test, value) do
    case String.starts_with?(purl, test) do
      false -> :no_match
      _ -> value
    end
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
