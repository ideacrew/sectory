defmodule SectoryEtl do
  def load_sbom_path(sbom_name, sbom_location) do
    SectoryEtl.Import.Sbom.load_sbom_path(sbom_name, sbom_location)
  end

  def import_sbom_map(sbom_name, sbom_map) do
    SectoryEtl.Import.Sbom.import_sbom_map(sbom_name, sbom_map)
  end
end
