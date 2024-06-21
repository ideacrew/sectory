defmodule Sectory.Records.VersionSbom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "version_sboms" do
    field :name, :string
    belongs_to :deliverable_version, Sectory.Records.DeliverableVersion
    has_one :sbom_content, Sectory.Records.SbomContent
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(version_sbom, params \\ %{}) do
    version_sbom
      |> cast(params, [:name, :deliverable_version_id])
      |> validate_required([:name, :deliverable_version_id])
      |> validate_length(:name, max: 256)
  end
end
