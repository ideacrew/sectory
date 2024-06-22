defmodule SectoryEtl.Export do
  import Ecto.Query

  @export_analysis_rows [
    "vulnerability_identifier",
    "deliverable_version_sha",
    "deliverable_version_version",
    "deliverable_version_deliverable_name",
    "deliverable_name",
    "detail"
  ]

  @export_sbom_rows [
    "sbom_name",
    "sbom_file"
  ]

  def export_sbom_and_analysis_package() do
    analyses_csv = export_analysis_records()
    sbom_query =
      from vs in Sectory.Records.VersionSbom,
      join: sc in assoc(vs, :sbom_content),
      select: %{
        sbom_name: vs.name,
        data: sc.data
      }
    sbom_stream = Sectory.Repo.stream(sbom_query)
    {:ok, path} = Briefly.create()
    Sectory.Repo.transaction(fn ->
      zstream = Zstream.zip(
        stream_sbom_query(sbom_stream, analyses_csv)
      )
      zstream
        |> Stream.into(File.stream!(path))
        |> Stream.run
    end)
    path
  end

  def stream_sbom_query(sbom_stream, analyses_csv) do
    Stream.transform(
      sbom_stream,
      fn() -> :starting end,
      fn ele, acc ->
        case acc do
          :starting ->
            {sbom_name, sbom_filename, sbom_entry} = filename_and_content_for(ele)
            {
              [
              Zstream.entry("analyses.csv", [analyses_csv]),
              Zstream.entry(sbom_filename, [sbom_entry])
              ],
            {:sboms, [[sbom_name, sbom_filename]]}
            }
          _ ->
            {sbom_name, sbom_filename, sbom_entry} = filename_and_content_for(ele)
            {:sboms, previous} = acc
            {[Zstream.entry(sbom_filename, [sbom_entry])], {:sboms, [[sbom_name, sbom_filename]|previous]}}
        end
      end,
      fn acc -> {manifest_entries_for(acc, analyses_csv), acc} end,
      fn _ -> :ok end
    )
  end

  def manifest_entries_for(:starting, analyses_csv) do
    [
      Zstream.entry("analyses.csv", [analyses_csv]),
      manifest_entry_for_sboms([])
    ]
  end

  def manifest_entries_for({:sboms, file_name_list}, analyses_csv) do
    [
      Zstream.entry("analyses.csv", [analyses_csv]),
      manifest_entry_for_sboms(file_name_list)
    ]
  end

  def manifest_entry_for_sboms(sbom_list) do
    Zstream.entry("sbom_manifest.csv", CSV.encode([@export_sbom_rows|sbom_list]))
  end

  def filename_and_content_for(sbom_entry) do
    uuid = Ecto.UUID.generate()
    generated_filename = "#{uuid}.json"
    {
      sbom_entry.sbom_name,
      generated_filename,
      Jason.encode!(sbom_entry.data)
    }
  end

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
        out_stream = transform_output_list(record_stream)

        Enum.join(CSV.encode(out_stream))
      end)

    result
  end

  defp transform_output_list(stream) do
    Stream.transform(
      stream,
      fn -> :headers end,
      fn ele, acc ->
        case acc do
          :headers ->
            {
              [
                @export_analysis_rows,
                analysis_to_csv_row(ele)
              ],
              :rows
            }

          _ ->
            {[analysis_to_csv_row(ele)], :rows}
        end
      end,
      fn acc ->
        case acc do
          :rows -> {:halt, acc}
          _ -> {[@export_analysis_rows], acc}
        end
      end,
      fn _ -> :ok end
    )
  end

  defp analysis_to_csv_row(record) do
    [
      record.vulnerability_identifier,
      record.deliverable_version_sha,
      record.deliverable_version_version,
      record.deliverable_version_deliverable_name,
      record.deliverable_name,
      record.detail
    ]
  end
end
