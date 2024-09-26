defmodule SectoryEtl.Export.ComponentListCsv do

  @export_component_rows [
    name: "name",
    version: "version",
    kind: "kind",
    purl: "purl",
    cpe: "cpe",
    description: "description"
  ]

  @spec export_component_list_csv(%Sectory.Records.VersionSbom{}) :: Enum.t()
  def export_component_list_csv(v_sbom) do
    data = v_sbom.sbom_content.data
    data
    |> Sectory.Sbom.Sbom.components()
    |> component_stream()
    |> CSV.encode([headers: @export_component_rows])
    |> Enum.to_list()
  end

  defp component_stream(components) do
    case Enum.any?(components) do
      false -> [%{}]
      _ -> Stream.map(components, fn(comp) ->
        %{
          name: Sectory.Sbom.Component.component_name(comp),
          version: Sectory.Sbom.Component.component_version(comp),
          kind: Sectory.Sbom.Component.component_kind(comp),
          purl: Sectory.Sbom.Component.component_purl(comp),
          cpe: Sectory.Sbom.Component.component_cpe(comp),
          description: Sectory.Sbom.Component.component_description(comp)
        }
      end)
    end
  end
end
