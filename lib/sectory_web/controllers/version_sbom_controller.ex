defmodule SectoryWeb.VersionSbomController do
  use SectoryWeb, :controller
  import Ecto.Query

  def show(conn, %{"id" => vs_id}) do
    record = Sectory.Repo.one!(
      from vs in Sectory.Records.VersionSbom,
      where: vs.id == ^vs_id,
      join: sc in assoc(vs, :sbom_content),
      preload: [:sbom_content]
    )
    conn
    |> assign(:page_title, "Deliverable")
    |> render_inertia(
      "VersionSboms/ShowComponent",
      %{
        version_sbom: encode_record(record)
      }
    )
  end

  defp encode_record(record) do
    %{
      sbom_content: %{
        data: record.sbom_content.data
      }
    }
  end
end
