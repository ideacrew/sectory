defmodule SectoryWeb.ExportsController do
  use SectoryWeb, :controller

  def sbom_and_analyses(conn, _params) do
    path = SectoryEtl.Export.export_sbom_and_analysis_package()
    result = conn
      |> put_resp_header("Content-disposition","attachment; filename=\"export.zip\"")
      |> put_resp_header("Content-Type", "application/octet-stream")
      |> send_file(200, path)
    Briefly.cleanup()
    result
  end

  def vulnerability_analyses(conn, _params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s[attachment; filename="vulnerability_analyses.csv"])
    |> put_status(200)
    |> resp(200, SectoryEtl.Export.export_analysis_records())
  end
end
