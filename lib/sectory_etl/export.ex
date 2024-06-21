defmodule SectoryEtl.Export do
  import Ecto.Query

  def export_analysis_records() do
    analyses_query =
      from vas in Sectory.Records.VulnerabilityAnalysisScope,
        join: va in assoc(vas, :vulnerability_analysis),
        left_join: d in assoc(vas, :deliverable),
        left_join: dv in assoc(vas, :deliverable_version),
        left_join: d2 in assoc(dv, :deliverable),
        select: %{
          vulnerability_identifier: vas.vulnerability_identifier,
          deliverable_version_sha: dv.git_sha,
          deliverable_version_version: dv.version,
          deliverable_version_deliverable_name: d2.name,
          deliverable_name: d.name,
          detail: va.detail
        }

    record_stream = Sectory.Repo.stream(analyses_query)

    {:ok, result} =
      Sectory.Repo.transaction(fn ->
        out_stream = Stream.map(record_stream, fn r -> analysis_to_csv_row(r) end)

        Enum.join(
          CSV.encode(
            out_stream,
            headers: [
              "vulnerability_identifier",
              "deliverable_version_sha",
              "deliverable_version_version",
              "deliverable_version_deliverable_name",
              "deliverable_name",
              "detail"
            ]
          )
        )
      end)

    result
  end

  defp analysis_to_csv_row(record) do
    %{
      "vulnerability_identifier" => record.vulnerability_identifier,
      "deliverable_version_sha" => record.deliverable_version_sha,
      "deliverable_version_version" => record.deliverable_version_version,
      "deliverable_version_deliverable_name" => record.deliverable_version_deliverable_name,
      "deliverable_name" => record.deliverable_name,
      "detail" => record.detail
    }
  end
end
