defmodule Sectory.Queries.DeliverableVersions do
  import Ecto.Query

  @moduledoc """
  Shared queries for Deliverable Versions.
  """

  @spec deliverable_version_with_preloads(any()) :: Ecto.Schema.t()
  def deliverable_version_with_preloads(dv_id) do
    Sectory.Repo.one!(
      from dv in Sectory.Records.DeliverableVersion,
        where: dv.id == ^dv_id,
        left_join: vs in assoc(dv, :version_sboms),
        join: d in assoc(dv, :deliverable),
        left_join: va in assoc(dv, :version_artifacts),
        left_join: fa in assoc(va, :file_artifact),
        preload: [deliverable: d, version_sboms: vs, version_artifacts: {va, file_artifact: fa}]
    )
  end

  def query_by_deliverable_name_version_and_sha(deliverable_name, nil, git_sha) do
    from dv in Sectory.Records.DeliverableVersion,
      join: d in assoc(dv, :deliverable),
      where:
        d.name == ^deliverable_name and
          dv.git_sha == ^git_sha and
          is_nil(dv.version)
  end

  def query_by_deliverable_name_version_and_sha(deliverable_name, version, nil) do
    from dv in Sectory.Records.DeliverableVersion,
      join: d in assoc(dv, :deliverable),
      where:
        d.name == ^deliverable_name and
          dv.version == ^version and
          is_nil(dv.git_sha)
  end

  def query_by_deliverable_name_version_and_sha(deliverable_name, version, git_sha) do
    from dv in Sectory.Records.DeliverableVersion,
      join: d in assoc(dv, :deliverable),
      where:
        d.name == ^deliverable_name and
          dv.git_sha == ^git_sha and
          dv.version == ^version
  end

  def query_by_deliverable_version_and_sha(d_record, nil, git_sha) do
    from dv in Sectory.Records.DeliverableVersion,
      where:
        dv.deliverable_id == ^d_record.id and
          is_nil(dv.version) and
          dv.git_sha == ^git_sha
  end

  def query_by_deliverable_version_and_sha(d_record, comp_version, nil) do
    from dv in Sectory.Records.DeliverableVersion,
      where:
        dv.deliverable_id == ^d_record.id and
          dv.version == ^comp_version and
          is_nil(dv.git_sha)
  end

  def query_by_deliverable_version_and_sha(d_record, comp_version, git_sha) do
    from dv in Sectory.Records.DeliverableVersion,
      where:
        dv.deliverable_id == ^d_record.id and
          dv.comp_version == ^comp_version and
          dv.git_sha == ^git_sha
  end
end
