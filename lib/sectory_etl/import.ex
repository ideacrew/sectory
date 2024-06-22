defmodule SectoryEtl.Import do

  @spec import_sbom_and_analysis_package(any()) :: :ok | {:error, :einval}
  def import_sbom_and_analysis_package(path) do
    with {:ok, zip} = :zip.zip_open(to_charlist(path), [:memory]) do
      {:ok, {_, sbm_data}} = :zip.zip_get(to_charlist("sbom_manifest.csv"), zip)
      sbom_manifest = read_sbom_manifest(sbm_data)
      Enum.each(sbom_manifest, fn(m_entry) ->
        f_name = m_entry["sbom_file"]
        s_name = m_entry["sbom_name"]
        {:ok, {_, sbom_data}} = :zip.zip_get(to_charlist(f_name), zip)
        SectoryEtl.Import.Sbom.load_sbom_string(s_name, sbom_data)
      end)
      {:ok, {_, va_data}} = :zip.zip_get(to_charlist("vulnerability_analyses.csv"), zip)
      SectoryEtl.Import.VulnerabilityAnalysis.create_vulnerability_analyses_from_string([va_data])
      :zip.zip_close(zip)
    end
  end

  def read_sbom_manifest(sbm_data) do
    csv = CSV.decode([sbm_data], headers: true)
    Enum.map(csv, fn({:ok, rec}) ->
      rec
    end)
  end

  # SectoryEtl.Import.import_sbom_and_analysis_package("/Users/tevans/Downloads/export.zip")
end
