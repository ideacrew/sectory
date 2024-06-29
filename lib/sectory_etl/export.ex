defmodule SectoryEtl.Export do
  import Ecto.Query

  @moduledoc """
  Perform exports and dumps of various records and data.
  """

  @export_analysis_rows [
    "vulnerability_identifier",
    "deliverable_version_sha",
    "deliverable_version_version",
    "deliverable_version_deliverable_name",
    "deliverable_name",
    "state",
    "justification",
    "response",
    "adjusted_severity",
    "detail"
  ]

  @export_sbom_rows [
    "sbom_name",
    "sbom_file"
  ]

  @export_artifact_rows [
    "deliverable_name",
    "deliverable_version_version",
    "deliverable_version_sha",
    "original_filename",
    "artifact_file"
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
    {:ok, path} = Briefly.create(type: :directory)
    {:ok, zip_path} = Briefly.create()
    File.mkdir(Path.join(path, "sboms"))
    File.mkdir(Path.join(path, "artifacts"))

    {:ok, file_list} =
      Sectory.Repo.transaction(fn ->
        file_list_stream = stream_sbom_query(sbom_stream, analyses_csv)

        Enum.map(file_list_stream, fn {fname, fs} ->
          f_path = Path.join([path, fname])
          out_file = File.open!(f_path, [:write, :binary])
          IO.binwrite(out_file, fs)
          File.close(out_file)
          to_charlist(fname)
        end)
      end)

    artifact_content_query =
      from va in Sectory.Records.VersionArtifact,
        join: fa in assoc(va, :file_artifact),
        join: fc in assoc(fa, :file_artifact_content),
        join: dv in assoc(va, :deliverable_version),
        join: d in assoc(dv, :deliverable),
        select: %{
          deliverable_version_version: dv.version,
          deliverable_version_sha: dv.git_sha,
          deliverable_name: d.name,
          original_file_name: va.original_filename,
          content: fc.content
        }

    artifact_content_stream = Sectory.Repo.stream(artifact_content_query)

    {:ok, artifact_file_list} =
      Sectory.Repo.transaction(fn _ ->
        artifact_file_stream = stream_artifact_query(artifact_content_stream)

        Enum.map(artifact_file_stream, fn {fname, fs} ->
          f_path = Path.join([path, fname])
          out_file = File.open!(f_path, [:write, :binary])
          IO.binwrite(out_file, fs)
          File.close(out_file)
          to_charlist(fname)
        end)
      end)

    :zip.create(to_charlist(zip_path), file_list ++ artifact_file_list, [
      {:cwd, to_charlist(path)},
      :verbose
    ])

    zip_path
  end

  defp stream_artifact_query(artifact_stream) do
    Stream.transform(
      artifact_stream,
      fn -> [] end,
      fn ele, acc ->
        {artifact_filename, artifact_csv_row, artifact_content} = artifact_data_for(ele)
        {[{artifact_filename, artifact_content}], [artifact_csv_row | acc]}
      end,
      fn acc -> {artifact_manifest_entries_for(acc), acc} end,
      fn _ -> :ok end
    )
  end

  defp artifact_data_for(entry) do
    uuid = Ecto.UUID.generate()
    generated_filename = Path.join(["artifacts", "#{uuid}.binary"])

    csv_row = [
      entry.deliverable_name,
      entry.deliverable_version_version,
      entry.deliverable_version_sha,
      entry.original_file_name,
      generated_filename
    ]

    {generated_filename, csv_row, entry.content}
  end

  defp artifact_manifest_entries_for(artifact_entries) do
    [
      {"artifact_manifest.csv", Enum.join(CSV.encode([@export_artifact_rows | artifact_entries]))}
    ]
  end

  defp stream_sbom_query(sbom_stream, analyses_csv) do
    sbom_stream =
      Stream.transform(
        sbom_stream,
        fn -> [] end,
        fn ele, acc ->
          {sbom_name, sbom_filename, sbom_entry} = filename_and_content_for(ele)
          {[{sbom_filename, sbom_entry}], [[sbom_name, sbom_filename] | acc]}
        end,
        fn acc -> {manifest_entries_for(acc), acc} end,
        fn _ -> :ok end
      )

    Stream.concat(
      [{"vulnerability_analyses.csv", analyses_csv}],
      sbom_stream
    )
  end

  defp manifest_entries_for(file_name_list) do
    [
      manifest_entry_for_sboms(file_name_list)
    ]
  end

  defp manifest_entry_for_sboms(sbom_list) do
    {"sbom_manifest.csv", Enum.join(CSV.encode([@export_sbom_rows | sbom_list]))}
  end

  defp filename_and_content_for(sbom_entry) do
    uuid = Ecto.UUID.generate()
    generated_filename = Path.join(["sboms", "#{uuid}.json"])

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
          state: va.state,
          justification: va.justification,
          response: va.response,
          adjusted_severity: va.adjusted_severity,
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
      record.state,
      record.justification,
      record.response,
      record.adjusted_severity,
      record.detail
    ]
  end
end
