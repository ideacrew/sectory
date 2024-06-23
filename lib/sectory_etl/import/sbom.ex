defmodule SectoryEtl.Import.Sbom do
  alias Sectory.Repo
  import Ecto.Query

  def load_sbom_path(sbom_name, sbom_location) do
    sbom_raw = File.read!(sbom_location)
    load_sbom_string(sbom_name, sbom_raw)
  end

  def load_sbom_string(sbom_name, sbom_string) do
    {:ok, data} = Jason.decode(sbom_string)
    import_sbom_map(sbom_name, data)
  end

  def import_sbom_map(sbom_name, sbom_map) do
    comp_name = get_in(sbom_map, ["metadata", "component", "name"])
    comp_version = get_in(sbom_map, ["metadata", "component", "version"])
    git_shas = get_in(sbom_map, ["metadata", "component", "hashes"])
    git_sha = case git_shas do
      [_a|_rest] -> extract_git_sha(git_shas)
      _ -> nil
    end
    create_sbom_chain(comp_name, comp_version, git_sha, sbom_name, sbom_map)
  end

  defp create_sbom_chain(comp_name, comp_version, git_sha, sbom_name, sbom_map) do
    d_record = create_deliverable(comp_name)
    dv_record = create_deliverable_version(d_record, comp_version, git_sha)
    vscs = Sectory.Records.VersionSbom.new(%{
      deliverable_version_id: dv_record.id,
      name: sbom_name
    })
    {:ok, vs} = Repo.insert(vscs)
    sccs = Sectory.Records.SbomContent.new(%{
      version_sbom_id: vs.id,
      data: sbom_map
    })
    {:ok, _} = Repo.insert(sccs)
  end

  defp create_deliverable(comp_name) do
    existing_record = Repo.get_by(Sectory.Records.Deliverable, name: comp_name)
    with nil <- existing_record do
      dcs = Sectory.Records.Deliverable.new(%{
        name: comp_name
      })
      {:ok, d_record} = Repo.insert(dcs)
      d_record
    end
  end

  defp create_deliverable_version(d_record, comp_version, git_sha) do
    find_query = case {comp_version, git_sha} do
      {nil,_} ->
        from dv in Sectory.Records.DeliverableVersion,
        where:
          dv.deliverable_id == ^d_record.id and
          is_nil(dv.version) and
          dv.git_sha == ^git_sha
      {_,nil} ->
            from dv in Sectory.Records.DeliverableVersion,
            where:
              dv.deliverable_id == ^d_record.id and
              dv.version == ^comp_version and
              is_nil(dv.git_sha)
      _ ->
        from dv in Sectory.Records.DeliverableVersion,
        where:
          dv.deliverable_id == ^d_record.id and
          dv.comp_version == ^comp_version and
          dv.git_sha == ^git_sha
    end
    existing_record = Repo.one(
      find_query
    )
    with nil <- existing_record do
      dvcs = Sectory.Records.DeliverableVersion.new(%{
        deliverable_id: d_record.id,
        version: comp_version,
        git_sha: git_sha
      })
      {:ok, dv_record} = Repo.insert(dvcs)
      dv_record
    end
  end

  defp extract_git_sha(git_shas) do
    sha1_sha = Enum.find(git_shas, nil, fn(term) ->
      case term["alg"] do
        "SHA-1" -> true
        _ -> false
      end
    end)
    case sha1_sha do
      %{} -> sha1_sha["content"]
      _ -> nil
    end
  end
end
