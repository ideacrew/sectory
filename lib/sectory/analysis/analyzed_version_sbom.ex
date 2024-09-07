defmodule Sectory.Analysis.AnalyzedVersionSbom do
  import Ecto.Query

  @moduledoc """
  Perform analysis against a given SBOM and update analysis and severity
  records accordingly.
  """

  def find_analyzed_record(version_sbom_id) do
    record = find_record(version_sbom_id)
    analyses_query = Sectory.Queries.VulnerabilityAnalysisScopes.scopes_for_sbom_version(record)
    analyses = Sectory.Repo.all(analyses_query)
    analysis = merge_analyses(record.sbom_content.data, analyses)
    {record, analysis}
  end

  def find_record(version_sbom_id) do
    Sectory.Repo.one!(
      from vs in Sectory.Records.VersionSbom,
        where: vs.id == ^version_sbom_id,
        join: sc in assoc(vs, :sbom_content),
        join: dv in assoc(vs, :deliverable_version),
        join: d in assoc(dv, :deliverable),
        preload: [:sbom_content, deliverable_version: [:deliverable]]
    )
  end

  def merge_analyses(sbom_data, analyses) do
    vuln_map =
      Map.new(
        analyses,
        fn a ->
          {a.vulnerability_identifier, a}
        end
      )

    vulnerabilities = sbom_data["vulnerabilities"]

    case is_list(vulnerabilities) do
      false ->
        sbom_data

      _ ->
        update_vulnerabilities(sbom_data, vuln_map)
    end
  end

  defp update_vulnerabilities(sbom_data, vuln_map) do
    Map.update!(sbom_data, "vulnerabilities", fn vs ->
      Enum.map(vs, fn v ->
        v
        |> merge_analysis_into_vulnerability(vuln_map)
      end)
    end)
  end

  defp merge_analysis_into_vulnerability(v, vuln_map) do
    vuln_id = v["id"]
    existing_analysis = v["analysis"]

    case {vuln_id, existing_analysis} do
      {nil, _} ->
        v

      {_, nil} ->
        case Map.has_key?(vuln_map, vuln_id) do
          false ->
            v

          _ ->
            v
            |> apply_vuln_analysis(vuln_map[vuln_id])
            |> update_vuln_severity(vuln_map[vuln_id])
        end

      _ ->
        v
    end
  end

  def apply_vuln_analysis(v, analysis_record) do
    Map.put(v, "analysis", scope_to_sbom_analysis(analysis_record))
  end

  def update_vuln_severity(v, analysis_record) do
    case Map.has_key?(v, "properties") do
      false ->
        Map.put(v, "properties", [
          %{
            "name" => "vuln-assign:analysis_severity",
            "value" => analysis_record.vulnerability_analysis.adjusted_severity
          }
        ])

      _ ->
        update_vuln_properties(v, analysis_record)
    end
  end

  defp update_vuln_properties(v, analysis_record) do
    Map.update!(v, "properties", fn props ->
      clean_props =
        props
        |> Enum.filter(fn prop ->
          prop["name"] == "vuln-assign:analysis_severity"
        end)

      [
        %{
          "name" => "vuln-assign:analysis_severity",
          "value" => analysis_record.vulnerability_analysis.adjusted_severity
        }
        | clean_props
      ]
    end)
  end

  defp scope_to_sbom_analysis(vas) do
    %{
      "state" => vas.vulnerability_analysis.state,
      "justification" => vas.vulnerability_analysis.justification,
      "response" => vas.vulnerability_analysis.response,
      "detail" => vas.vulnerability_analysis.detail,
      "firstIssued" => vas.inserted_at,
      "lastUpdated" => vas.updated_at
    }
  end
end
