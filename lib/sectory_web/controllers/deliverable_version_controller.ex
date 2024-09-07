defmodule SectoryWeb.DeliverableVersionController do
  use SectoryWeb, :controller

  def show(conn, %{"id" => dv_id}) do
    record = Sectory.Queries.DeliverableVersions.deliverable_version_with_preloads(dv_id)
    conn
      |> render_inertia(
        "DeliverableVersions/ShowComponent",
        %{
          deliverable_version: encode_record(record)
        }
      )
  end

  def new(conn, params) do
    deliverable = Sectory.Repo.get!(Sectory.Records.Deliverable, params["deliverable_id"])
    conn
      |> render_inertia(
        "DeliverableVersions/NewComponent",
        %{
          deliverable_id: deliverable.id,
          deliverable_name: deliverable.name,
          create_url: ~p"/deliverables/#{deliverable.id}/deliverable_versions"
        }
      )
  end

  def create(conn, params) do
    deliverable_id = params["deliverable_id"]
    cs = Sectory.Records.DeliverableVersion.new(params)
    case cs.valid? do
      false ->
        conn
          |> assign_errors(cs)
          |> redirect(to: ~p"/deliverables/#{deliverable_id}/deliverable_versions/new")
      _ ->
        {:ok, _} = Sectory.Repo.insert(cs)
        conn
          |> redirect(to: ~p"/deliverables/#{deliverable_id}")
    end
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
          analyzed_version_sbom_url: ~p"/version_sboms/#{vs.id}/analyzed",
          vulnerability_report_download_url: ~p"/sbom_vulnerability_reports/#{vs.id}"
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
