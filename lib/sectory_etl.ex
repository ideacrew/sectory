defmodule SectoryEtl do
  def load_sbom_path(sbom_name, sbom_location) do
    SectoryEtl.Import.Sbom.load_sbom_path(sbom_name, sbom_location)
  end
end
