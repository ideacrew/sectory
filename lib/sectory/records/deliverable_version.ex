defmodule Sectory.Records.DeliverableVersion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deliverable_versions" do
    field :version, :string
    field :git_sha, :string
    belongs_to :deliverable, Sectory.Records.Deliverable
    has_many :version_sboms, Sectory.Records.VersionSbom
    has_many :version_artifacts, Sectory.Records.VersionArtifact
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(deliverable_version, params \\ %{}) do
    deliverable_version
      |> cast(params, [:version, :git_sha, :deliverable_id])
      |> validate_required([:deliverable_id])
      |> validate_length(:version, max: 128)
      |> validate_length(:git_sha, max: 128)
  end
end
