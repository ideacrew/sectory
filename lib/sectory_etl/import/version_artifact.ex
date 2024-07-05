defmodule SectoryEtl.Import.VersionArtifact do
  import Ecto.Query

  @moduledoc """
  Import version artifacts.

  Currently offers import abilities for a minimal data-set file and from
  the previously exported CSV format.
  """

  def import_version_artifact_with_id(deliverable_version_id, orig_file_name, artifact_content) do
    with {:ok, existing_data} <- check_artifact_content_exists(artifact_content) do
      case existing_data do
        %Sectory.Records.FileArtifact{} ->
          build_with_existing_artifact(deliverable_version_id, orig_file_name, existing_data)

        _ ->
          build_with_new_file_artifact(
            deliverable_version_id,
            orig_file_name,
            artifact_content,
            existing_data
          )
      end
    end
  end

  def build_record_from_csv_row(csv_row, content) do
    dv = find_or_create_deliverable_version(csv_row)
    import_version_artifact_with_id(dv.id, csv_row["original_filename"], content)
  end

  defp find_or_create_deliverable_version(csv_row) do
    git_sha = cast_val(csv_row["deliverable_version_sha"])
    version = cast_val(csv_row["deliverable_version_version"])
    deliverable_name = csv_row["deliverable_name"]

    deliverable_query =
      from d in Sectory.Records.Deliverable,
        where: d.name == ^deliverable_name

    deliverable_version_query =
      Sectory.Queries.DeliverableVersions.query_by_deliverable_name_version_and_sha(
        deliverable_name,
        version,
        git_sha
      )

    case Sectory.Repo.one(deliverable_version_query) do
      nil ->
        case Sectory.Repo.one(deliverable_query) do
          nil ->
            build_deliverable(deliverable_name)
            |> build_deliverable_version(git_sha, version)

          d ->
            build_deliverable_version(d, git_sha, version)
        end

      dvr ->
        dvr
    end
  end

  defp build_deliverable(deliverable_name) do
    cs =
      Sectory.Records.Deliverable.new(%{
        name: deliverable_name
      })

    {:ok, rec} = Sectory.Repo.insert(cs)
    rec
  end

  defp build_deliverable_version(deliverable, git_sha, version) do
    cs =
      Sectory.Records.DeliverableVersion.new(%{
        deliverable_id: deliverable.id,
        git_sha: git_sha,
        version: version
      })

    {:ok, rec} = Sectory.Repo.insert(cs)
    rec
  end

  defp build_with_new_file_artifact(
         deliverable_version_id,
         orig_file_name,
         artifact_content,
         artifact_data
       ) do
    fa_cs = Sectory.Records.FileArtifact.new(artifact_data)

    with {:ok, fa} <- Sectory.Repo.insert(fa_cs) do
      fac_cs =
        Sectory.Records.FileArtifactContent.new(%{
          file_artifact_id: fa.id,
          content: artifact_content
        })

      with {:ok, _} <- Sectory.Repo.insert(fac_cs) do
        cs =
          Sectory.Records.VersionArtifact.new(%{
            deliverable_version_id: deliverable_version_id,
            original_filename: orig_file_name,
            file_artifact_id: fa.id
          })

        Sectory.Repo.insert(cs)
      end
    end
  end

  defp build_with_existing_artifact(deliverable_version_id, orig_file_name, existing_artifact) do
    cs =
      Sectory.Records.VersionArtifact.new(%{
        deliverable_version_id: deliverable_version_id,
        original_filename: orig_file_name,
        file_artifact_id: existing_artifact.id
      })

    Sectory.Repo.insert(cs)
  end

  defp check_artifact_content_exists(artifact_contents) do
    artifact_data = calculate_artifact_size_and_length(artifact_contents)

    possible_version_artifact_query =
      from va in Sectory.Records.VersionArtifact,
        join: fa in assoc(va, :file_artifact),
        where:
          fa.size == ^artifact_data[:size] and
            fa.sha256 == ^artifact_data[:sha256] and
            fa.sha384 == ^artifact_data[:sha384] and
            fa.sha512 == ^artifact_data[:sha512]

    va = Sectory.Repo.one(possible_version_artifact_query)

    case va do
      nil -> check_file_artifact_exists(artifact_data)
      _ -> {:error, va}
    end
  end

  defp check_file_artifact_exists(artifact_data) do
    possible_file_artifact_query =
      from fa in Sectory.Records.FileArtifact,
        where:
          fa.size == ^artifact_data[:size] and
            fa.sha256 == ^artifact_data[:sha256] and
            fa.sha384 == ^artifact_data[:sha384] and
            fa.sha512 == ^artifact_data[:sha512]

    fa = Sectory.Repo.one(possible_file_artifact_query)

    case fa do
      nil -> {:ok, artifact_data}
      _ -> {:ok, fa}
    end
  end

  defp calculate_artifact_size_and_length(artifact_data) do
    length = byte_size(artifact_data)
    sha256_hash = :crypto.hash(:sha256, artifact_data)
    sha384_hash = :crypto.hash(:sha384, artifact_data)
    sha512_hash = :crypto.hash(:sha512, artifact_data)

    %{
      size: length,
      sha256: Base.encode16(sha256_hash, case: :lower),
      sha384: Base.encode16(sha384_hash, case: :lower),
      sha512: Base.encode16(sha512_hash, case: :lower)
    }
  end

  defp cast_val(nil), do: nil
  defp cast_val(""), do: nil
  defp cast_val([]), do: nil
  defp cast_val(a), do: a
end
