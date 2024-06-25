defmodule Sectory.Records.VersionSbom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "version_sboms" do
    field :name, :string
    field :length, :integer
    field :sha256, :string
    field :sha384, :string
    field :sha512, :string
    belongs_to :deliverable_version, Sectory.Records.DeliverableVersion
    has_one :sbom_content, Sectory.Records.SbomContent
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(version_sbom, params \\ %{}) do
    version_sbom
    |> cast(params, [
      :name,
      :deliverable_version_id,
      :length,
      :sha256,
      :sha384,
      :sha512
    ])
    |> validate_required([
      :name,
      :deliverable_version_id,
      :length,
      :sha256,
      :sha384,
      :sha512
    ])
    |> validate_length(:name, max: 256)
    |> validate_length(:sha256, max: 512)
    |> validate_length(:sha384, max: 768)
    |> validate_length(:sha512, max: 1024)
  end
end
