defmodule Sectory.Records.VersionArtifact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "version_artifacts" do
    field :original_filename, :string
    belongs_to :deliverable_version, Sectory.Records.DeliverableVersion
    belongs_to :file_artifact, Sectory.Records.FileArtifact
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(version_sbom, params \\ %{}) do
    version_sbom
    |> cast(params, [
      :original_filename,
      :deliverable_version_id,
      :file_artifact_id
    ])
    |> validate_required([
      :original_filename,
      :deliverable_version_id,
      :file_artifact_id
    ])
    |> validate_length(:original_filename, max: 512)
  end
end
