defmodule SectoryWeb.VersionArtifactController do
  use SectoryWeb, :controller
  import Ecto.Query

  def download(conn, %{"id" => va_id}) do
    record = Sectory.Repo.one!(
      from va in Sectory.Records.VersionArtifact,
      where: va.id == ^va_id,
      join: fa in assoc(va, :file_artifact),
      join: fc in assoc(fa, :file_artifact_content),
      preload: [file_artifact: {fa, file_artifact_content: fc}]
    )
    conn
      |> put_resp_header("Content-Type", "application/octet-stream")
      |> put_resp_header("Content-disposition","attachment; filename=\"#{record.original_filename}\"")
      |> send_resp(200, record.file_artifact.file_artifact_content.content)
  end
end
