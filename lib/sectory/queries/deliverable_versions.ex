defmodule Sectory.Queries.DeliverableVersions do
  import Ecto.Query

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

  def query_by_deliverable_name_version_and_sha(deliverable_name, version, git_sha) do
    case {git_sha, version} do
      {nil, v} ->
        from dv in Sectory.Records.DeliverableVersion,
          join: d in assoc(dv, :deliverable),
          where:
            d.name == ^deliverable_name and
              dv.version == ^v and
              is_nil(dv.git_sha)

      {s, nil} ->
        from dv in Sectory.Records.DeliverableVersion,
          join: d in assoc(dv, :deliverable),
          where:
            d.name == ^deliverable_name and
              dv.git_sha == ^s and
              is_nil(dv.version)

      _ ->
        from dv in Sectory.Records.DeliverableVersion,
          join: d in assoc(dv, :deliverable),
          where:
            d.name == ^deliverable_name and
              dv.git_sha == ^git_sha and
              dv.version == ^version
    end
  end
end
