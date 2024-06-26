defmodule SectoryWeb.DeliverableVersionController do
  use SectoryWeb, :controller
  import Ecto.Query

  def show(conn, %{"id" => dv_id}) do
    record = Sectory.Repo.one!(
      from dv in Sectory.Records.DeliverableVersion,
      where: dv.id == ^dv_id,
      left_join: vs in assoc(dv, :version_sboms),
      join: d in assoc(dv, :deliverable),
      left_join: va in assoc(dv, :version_artifacts),
      left_join: fa in assoc(va, :file_artifact),
      preload: [deliverable: d, version_sboms: vs, version_artifacts: {va, file_artifact: fa}]
    )
    conn
      |> render_inertia(
        "DeliverableVersions/ShowComponent",
        %{
          deliverable_version: encode_record(record)
        }
      )
  end

  defp encode_record(record) do
    %{
      id: record.id,
      git_sha: record.git_sha,
      version: record.version,
      deliverable: %{
        id: record.deliverable.id,
        name: record.deliverable.name
      },
      version_sboms: Enum.map(record.version_sboms, fn(vs) ->
        %{
          id: vs.id,
          name: vs.name,
          version_sbom_url: ~p"/version_sboms/#{vs.id}",
          analyzed_version_sbom_url: ~p"/version_sboms/#{vs.id}/analyzed"
        }
      end),
      version_artifacts: Enum.map(record.version_artifacts, fn(va) ->
        %{
          id: va.id,
          original_filename: va.original_filename,
          size: va.file_artifact.size,
          download_url: ~p"/version_artifacts/#{va.id}/download"
        }
      end)
    }
  end
end
