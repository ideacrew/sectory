defmodule Sectory.Records.SbomContent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sbom_contents" do
    field :data, :map, default: %{}
    belongs_to :version_sbom, Sectory.Records.VersionSbom
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(sbom_contents, params \\ %{}) do
    sbom_contents
      |> cast(params, [:version_sbom_id, :data])
      |> validate_required([:version_sbom_id])
  end
end
