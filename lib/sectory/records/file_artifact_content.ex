defmodule Sectory.Records.FileArtifactContent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "file_artifact_contents" do
    field :content, :binary
    belongs_to :file_artifact, Sectory.Records.FileArtifact
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(sbom_contents, params \\ %{}) do
    sbom_contents
      |> cast(params, [:file_artifact_id, :content])
      |> validate_required([:file_artifact_id])
  end
end
