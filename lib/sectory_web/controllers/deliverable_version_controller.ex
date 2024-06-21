defmodule SectoryWeb.DeliverableVersionController do
  use SectoryWeb, :controller
  import Ecto.Query

  def show(conn, %{"id" => dv_id}) do
    record = Sectory.Repo.one!(
      from dv in Sectory.Records.DeliverableVersion,
      where: dv.id == ^dv_id,
      join: vs in assoc(dv, :version_sboms),
      join: d in assoc(dv, :deliverable),
      preload: [:deliverable, :version_sboms]
    )
    conn
      |> assign(:page_title, "Deliverable")
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
      end)
    }
  end
end
