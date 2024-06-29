defmodule Sectory.Records.DeliverableVersion do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  A particular version of a deliverable.
  """

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
      |> validate_version_or_sha()
  end

  def validate_version_or_sha(changeset) do
    version_change = cast_blanks(get_change(changeset, :version))
    sha_change = cast_blanks(get_change(changeset, :git_sha))
    case {version_change, sha_change} do
      {nil, nil} ->
        changeset
        |> add_error(:git_sha, "git sha or version must be specified")
        |> add_error(:version, "git sha or version must be specified")
      _ -> changeset
    end
  end

  def cast_blanks(nil), do: nil
  def cast_blanks(nil), do: nil
  def cast_blanks(a), do: a
end
