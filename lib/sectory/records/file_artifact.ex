defmodule Sectory.Records.FileArtifact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "file_artifacts" do
    field :size, :integer
    field :sha256, :string
    field :sha384, :string
    field :sha512, :string
    has_one :file_artifact_content, Sectory.Records.FileArtifactContent
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(version_sbom, params \\ %{}) do
    version_sbom
    |> cast(params, [
      :size,
      :sha256,
      :sha384,
      :sha512
    ])
    |> validate_required([
      :size,
      :sha256,
      :sha384,
      :sha512
    ])
    |> validate_length(:sha256, max: 512)
    |> validate_length(:sha384, max: 768)
    |> validate_length(:sha512, max: 1024)
  end
end
