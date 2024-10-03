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
    |> render_inertia(
      "VersionSboms/ShowComponent",
      %{
        version_sbom: encode_record(record, record.sbom_content.data)
      }
    )
  end

  def analyzed(conn, %{"id" => vs_id}) do
    {record, analysis} = Sectory.Analysis.AnalyzedVersionSbom.find_analyzed_record(vs_id)
    conn
    |> assign(:page_title, "Deliverable")
    |> render_inertia(
      "VersionSboms/ShowComponent",
      %{
        version_sbom: encode_record(record, analysis)
      }
    )
  end

  def exportable(conn, %{"id" => vs_id}) do
    {record, analysis} = Sectory.Analysis.AnalyzedVersionSbom.find_analyzed_record(vs_id)
    conn
    |> assign(:skip_main_layout, true)
    |> assign(:page_title, "Deliverable")
    |> render_inertia(
      "VersionSboms/ShowComponent",
      Map.merge(%{
        version_sbom: encode_record(record, analysis)
      }, %{disallow_analysis: true})
    )
  end

  def component_export(conn, %{"id" => vs_id}) do
    record = Sectory.Repo.one!(
      from vs in Sectory.Records.VersionSbom,
      where: vs.id == ^vs_id,
      join: sc in assoc(vs, :sbom_content),
      preload: [:sbom_content]
    )
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s[attachment; filename="#{vs_id}.csv"])
    |> put_status(200)
    |> resp(200, Enum.join(SectoryEtl.Export.export_component_list_csv(record), ""))
  end

  defp encode_record(record, sbom_data) do
    %{
      id: record.id,
      deliverable_version: %{
        id: record.deliverable_version_id,
        analysis_url: ~p"/vulnerability_analyses/new?suggested_deliverable_version_id=#{record.deliverable_version_id}"
      },
      sbom_content: %{
        data: sbom_data
      }
    }
  end
end
