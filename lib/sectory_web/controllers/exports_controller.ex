defmodule SectoryWeb.ExportsController do
  use SectoryWeb, :controller

  def vulnerability_analyses(conn, _params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s[attachment; filename="vulnerability_analyses.csv"])
    |> put_status(200)
    |> resp(200, SectoryEtl.Export.export_analysis_records())
  end
end
