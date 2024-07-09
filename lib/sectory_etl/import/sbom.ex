defmodule SectoryEtl.Import.Sbom do
  alias Sectory.Repo
  import Ecto.Query

  @moduledoc """
  Import SBOMS, from either a raw format or specialized export.
  """

  def load_sbom_path(sbom_name, sbom_location) do
    sbom_raw = File.read!(sbom_location)
    load_sbom_string(sbom_name, sbom_raw)
  end

  def load_sbom_string(sbom_name, sbom_string) do
    {:ok, data} = Jason.decode(sbom_string)
    import_sbom_map(sbom_name, data, sbom_string)
  end

  def import_sbom_map(sbom_name, sbom_map, sbom_string) do
    comp_name = get_in(sbom_map, ["metadata", "component", "name"])
    comp_version = get_in(sbom_map, ["metadata", "component", "version"])
    git_shas = get_in(sbom_map, ["metadata", "component", "hashes"])

    git_sha =
      case git_shas do
        [_a | _rest] -> extract_git_sha(git_shas)
        _ -> nil
      end

    create_sbom_chain(comp_name, comp_version, git_sha, sbom_name, sbom_map, sbom_string)
  end

  defp create_sbom_chain(comp_name, comp_version, git_sha, sbom_name, sbom_map, sbom_string) do
    d_record = create_deliverable(comp_name)
    dv_record = create_deliverable_version(d_record, comp_version, git_sha)

    with {:ok, sbom_hashes} <- check_existing_sbom(sbom_string) do
      vscs =
        Sectory.Records.VersionSbom.new(
          Map.merge(
            %{
              deliverable_version_id: dv_record.id,
              name: sbom_name
            },
            sbom_hashes
          )
        )

      {:ok, vs} = Repo.insert(vscs)

      sccs =
        Sectory.Records.SbomContent.new(%{
          version_sbom_id: vs.id,
          data: sbom_map
        })

      Repo.insert(sccs)
    end
  end

  defp check_existing_sbom(sbom_string) do
    sbom_data = calculate_sbom_shas_and_length(sbom_string)

    query =
      from vs in Sectory.Records.VersionSbom,
        where:
          vs.size == ^sbom_data[:size] and
            vs.sha256 == ^sbom_data[:sha256] and
            vs.sha384 == ^sbom_data[:sha384] and
            vs.sha512 == ^sbom_data[:sha512]

    result = Sectory.Repo.one(query)

    case result do
      nil -> {:ok, sbom_data}
      _ -> {:error, result}
    end
  end

  defp create_deliverable(comp_name) do
    existing_record = Repo.get_by(Sectory.Records.Deliverable, name: comp_name)

    with nil <- existing_record do
      dcs =
        Sectory.Records.Deliverable.new(%{
          name: comp_name
        })

      {:ok, d_record} = Repo.insert(dcs)
      d_record
    end
  end

  defp create_deliverable_version(d_record, comp_version, git_sha) do
    find_query =
      Sectory.Queries.DeliverableVersions.query_by_deliverable_version_and_sha(
        d_record,
        comp_version,
        git_sha
      )

    existing_record = Repo.one(find_query)

    with nil <- existing_record do
      dvcs =
        Sectory.Records.DeliverableVersion.new(%{
          deliverable_id: d_record.id,
          version: comp_version,
          git_sha: git_sha
        })

      {:ok, dv_record} = Repo.insert(dvcs)
      dv_record
    end
  end

  defp extract_git_sha(git_shas) do
    sha1_sha =
      Enum.find(git_shas, nil, fn term ->
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

  defp calculate_sbom_shas_and_length(sbom_string) do
    length = byte_size(sbom_string)
    sha256_hash = :crypto.hash(:sha256, sbom_string)
    sha384_hash = :crypto.hash(:sha384, sbom_string)
    sha512_hash = :crypto.hash(:sha512, sbom_string)

    %{
      size: length,
      sha256: Base.encode16(sha256_hash, case: :lower),
      sha384: Base.encode16(sha384_hash, case: :lower),
      sha512: Base.encode16(sha512_hash, case: :lower)
    }
  end
end
