defmodule Sectory.Analysis.AnalyzedVersionSbom do
  import Ecto.Query

  def find_analyzed_record(version_sbom_id) do
    record = find_record(version_sbom_id)
    analysis = apply_analysis_to_sbom(record)
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

  defp apply_analysis_to_sbom(sbom_version) do
    version_id = sbom_version.deliverable_version_id
    deliverable_id = sbom_version.deliverable_version.deliverable_id
    sbom_data = sbom_version.sbom_content.data
    vuln_ids = extract_vulnerability_ids(sbom_data)
    analyses_query =
      from vas in Sectory.Records.VulnerabilityAnalysisScope,
        join: va in assoc(vas, :vulnerability_analysis),
        preload: :vulnerability_analysis,
        where:
          vas.deliverable_version_id == ^version_id or
            (vas.deliverable_id == ^deliverable_id and is_nil(vas.deliverable_version_id)) or
            (is_nil(vas.deliverable_id) and is_nil(vas.deliverable_id) and vas.vulnerability_identifier in ^vuln_ids)
    analyses = Sectory.Repo.all(analyses_query)
    merge_analyses(sbom_data, analyses)
  end

  defp merge_analyses(sbom_data, analyses) do
    vuln_map = Map.new(analyses,
     fn(a) ->
       {a.vulnerability_identifier, scope_to_sbom_analysis(a)}
     end)
    vulnerabilities = sbom_data["vulnerabilities"]
    case is_list(vulnerabilities) do
      false -> sbom_data
      _ -> Map.update!(sbom_data, "vulnerabilities", fn(vs) ->
        Enum.map(vs, fn(v) -> merge_analysis_into_vulnerability(v, vuln_map) end)
      end)
    end
  end

  defp merge_analysis_into_vulnerability(v, vuln_map) do
    vuln_id = v["id"]
    existing_analysis = v["analysis"]
    case {vuln_id, existing_analysis} do
      {nil, _} -> v
      {a, nil} ->
        case Map.has_key?(vuln_map, vuln_id) do
          false -> v
          _ -> Map.put(v, "analysis", vuln_map[vuln_id])
        end
      _ -> v
    end
  end

  defp scope_to_sbom_analysis(vas) do
    %{
      state: vas.vulnerability_analysis.state,
      justification: vas.vulnerability_analysis.justification,
      response: vas.vulnerability_analysis.response,
      detail: vas.vulnerability_analysis.detail
    }
  end

  defp extract_vulnerability_ids(sbom_data) do
    vulnerabilities = get_in(sbom_data, ["vulnerabilities"])

    case is_list(vulnerabilities) do
      false ->
        []

      _ ->
        for item <- vulnerabilities, item["id"] != nil do
          item["id"]
        end
    end
  end
end
