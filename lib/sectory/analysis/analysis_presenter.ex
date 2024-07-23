defmodule Sectory.Analysis.AnalysisPresenter do
  @moduledoc """
  Organize an analysis into an object I can report on.
  """

  defstruct [
    :component_name,
    :component_version,
    :analysis_timestamp,
    :analyses,
    :totals,
    :all_issue_totals
  ]

  def for_sbom_id(version_sbom_id) do
    sbom = Sectory.Analysis.AnalyzedVersionSbom.find_record(version_sbom_id)
    analyses_query = Sectory.Queries.VulnerabilityAnalysisScopes.scopes_for_sbom_version(sbom)
    sbom_data = sbom.sbom_content.data
    analyses = Sectory.Repo.all(analyses_query)
    analysis = Sectory.Analysis.AnalyzedVersionSbom.merge_analyses(sbom_data, analyses)
    component_map = component_lookup_map(sbom_data)
    vulns = map_vulnerabilities(analysis, component_map)

    totals =
      vulns
      |> Enum.group_by(fn v ->
        {v[:severity], v[:potential]}
      end)
      |> Enum.into(%{}, fn {k, v} -> {k, Enum.count(v)} end)

    all_issue_totals =
      totals
      |> Enum.group_by(fn {k, _v} -> elem(k, 0) end, fn {k, v} -> v end)
      |> Enum.into(%{}, fn {k, v} -> {k, Enum.sum(v)} end)

    %__MODULE__{
      component_name: Sectory.Sbom.Component.main_component_name(analysis),
      component_version: Sectory.Sbom.Component.main_component_version(analysis),
      analysis_timestamp: analysis_timestamp(analysis),
      analyses: analyses,
      totals: totals,
      all_issue_totals: all_issue_totals
    }
  end

  def map_vulnerabilities(analysis, component_map) do
    vulns = Map.get(analysis, "vulnerabilities", [])

    Enum.map(vulns, fn v ->
      format_vuln(v, component_map)
    end)
  end

  def format_vuln(v, component_map) do
    %{
      id: v["id"],
      severity: Sectory.Sbom.Vulnerability.format_severity(v),
      potential: Sectory.Sbom.Vulnerability.potential?(v)
    }
  end

  def component_lookup_map(sbom_data) do
    Map.new(
      sbom_data["components"],
      fn a ->
        {a["bom-ref"], a}
      end
    )
  end

  defp analysis_timestamp(analysis) do
    Date.utc_today()
  end
end
