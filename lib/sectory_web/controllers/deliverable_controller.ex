defmodule SectoryWeb.DeliverableController do
  use SectoryWeb, :controller
  import Ecto.Query

  def index(conn, _params) do
    records = Sectory.Repo.all(Sectory.Records.Deliverable)
    conn
      |> render_inertia("Deliverables/IndexComponent", %{deliverables: encode_records(records)})
  end

  def show(conn, %{"id" => d_id}) do
    record = Sectory.Repo.get!(Sectory.Records.Deliverable, d_id)
    records = Sectory.Repo.all(
      from dv in Sectory.Records.DeliverableVersion,
      where: dv.deliverable_id == ^d_id,
      join: d in assoc(dv, :deliverable),
      preload: :deliverable
    )
    conn
      |> render_inertia(
        "Deliverables/ShowComponent",
        %{
          deliverable: encode_deliverable(record, records)
        }
        )
  end

  defp encode_records(records) do
    Enum.map(records, fn(r) ->
     %{
       id: r.id,
       name: r.name,
       versions_url: ~p"/deliverables/#{r.id}"
     }
    end)
  end

  defp encode_deliverable(d, dvs) do
     %{
       id: d.id,
       name: d.name,
       deliverable_versions: Enum.map(dvs, fn(dv) ->
         %{
          id: dv.id,
          git_sha: dv.git_sha,
          version: dv.version,
          deliverable_version_url: ~p"/deliverable_versions/#{dv.id}"
         }
       end)
     }
  end
end
