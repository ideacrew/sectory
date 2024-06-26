defmodule SectoryWeb.HomeController do
  use SectoryWeb, :controller
  import Ecto.Query

  def index(conn, _params) do
    conn
      |> render_inertia(
           "Home/IndexComponent",
           %{
              deliverables_url: ~p"/deliverables",
              stats: get_stats()
           }
         )
  end

  defp get_stats() do
    d_query = (
      from d in Sectory.Records.Deliverable,
      select: count()
    )
    dv_query = (
      from dv in Sectory.Records.DeliverableVersion,
      select: count()
    )
    sbom_query = (
      from sbom in Sectory.Records.VersionSbom,
      select: count()
    )
    va_query = (
      from sbom in Sectory.Records.VersionArtifact,
      select: count()
    )
    a_query = (
      from a in Sectory.Records.VulnerabilityAnalysis,
      select: count()
    )
    %{
      deliverables: Sectory.Repo.one(d_query),
      versions: Sectory.Repo.one(dv_query),
      sboms: Sectory.Repo.one(sbom_query),
      artifacts: Sectory.Repo.one(va_query),
      analyses: Sectory.Repo.one(a_query)
    }
  end
end
