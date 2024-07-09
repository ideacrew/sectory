defmodule Mix.Tasks.Sbom do
  use Mix.Task

  @moduledoc """
  Build a CycloneDX SBOM for the hex packages.
  """
  @shortdoc "Build an sbom."

  @impl Mix.Task
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, [switches: [output: :string]])
    loaded_opts = [env: :prod, target: Mix.target()]

    components =
      Mix.Dep.Converger.converge(loaded_opts)
      |> Enum.sort_by(& &1.app)
      |> Enum.map(fn c ->
        component_from_dep(c)
      end)
    case opts[:output] do
      nil ->
        shell = Mix.shell()
        shell.info(produce_sbom(components))
      _ ->
        f = File.open!(opts[:output], [:write, :binary])
        IO.write(f, produce_sbom(components))
        File.close(f)
    end
  end

  defp produce_sbom(components) do
    Jason.encode!(
      %{
        bomFormat: "CycloneDX",
        specVersion: "1.5",
        metadata: %{
          component: application_component()
        },
        components: Enum.map(components, fn(c) ->
          Map.put(c, "bom-ref", c[:name] <> "-" <> uuid())
        end)
      }
    )
  end

  defp application_component() do
    %{
      type: "application",
      name: "sectory"
    }
  end

  defp component_from_dep(%{opts: opts} = dep) do
    case Map.new(opts) do
      %{optional: true} ->
        # If the dependency is optional at the top level, then we don't include
        # it in the SBoM
        nil

      opts_map ->
        component_from_dep(dep, opts_map)
    end
  end

  defp component_from_dep(%{scm: Mix.SCM.Git, app: app}, opts) do
    %{git: git, lock: lock, dest: _dest} = opts

    version =
      case opts[:tag] do
        nil ->
          elem(lock, 2)

        tag ->
          tag
      end

    %{
      type: "library",
      name: to_string(app),
      version: version,
      purl: git(to_string(app), git, version),
      licenses: []
    }
  end

  defp component_from_dep(%{scm: Hex.SCM}, opts) do
    %{hex: name, lock: lock, dest: dest} = opts
    version = elem(lock, 2)
    sha256 = elem(lock, 3)

    hex_metadata_path = Path.expand("hex_metadata.config", dest)

    metadata =
      case :file.consult(hex_metadata_path) do
        {:ok, metadata} -> metadata
        _ -> []
      end

    {_, description} = List.keyfind(metadata, "description", 0, {"description", ""})
    # {_, licenses} = List.keyfind(metadata, "licenses", 0, {"licenses", []})

    %{
      type: "library",
      name: name,
      version: version,
      purl: hex(name, version, opts[:repo]),
      # cpe: Cpe.hex(name, version, opts[:repo]),
      hashes: [%{
        alg: "SHA-256",
        content: sha256
      }],
      description: description,
      licenses: []
    }
  end

  defp hex(name, version, repo) do
    do_hex(String.downcase(name), version, String.downcase(repo))
  end

  defp do_hex(name, version, "hexpm") do
    purl(["hex", name], version)
  end

  defp do_hex(name, version, "hexpm:" <> organization) do
    purl(["hex", organization, name], version)
  end

  defp do_hex(name, version, repo) do
    case Hex.Repo.fetch_repo(repo) do
      {:ok, %{url: url}} ->
        purl(["hex", name], version, repository_url: url)

      :error ->
        raise "Undefined Hex repo: #{repo}"
    end
  end

  defp git(_name, "git@github.com:" <> github, commit_or_tag) do
    github |> String.replace_suffix(".git", "") |> github(commit_or_tag)
  end

  defp git(_name, "https://github.com/" <> github, commit_or_tag) do
    github |> String.replace_suffix(".git", "") |> github(commit_or_tag)
  end

  defp git(_name, "git@bitbucket.org:" <> bitbucket, commit_or_tag) do
    bitbucket |> String.replace_suffix(".git", "") |> bitbucket(commit_or_tag)
  end

  defp git(_name, "https://bitbucket.org/" <> bitbucket, commit_or_tag) do
    bitbucket |> String.replace_suffix(".git", "") |> bitbucket(commit_or_tag)
  end

  # Git dependence other than GitHub and BitBucket are not currently supported
  defp git(_name, _git, _commit_or_tag), do: nil

  defp github(github, commit_or_tag) do
    [organization, repository | _] = String.split(github, "/")
    name = repository |> String.downcase()
    purl(["github", String.downcase(organization), name], commit_or_tag)
  end

  defp bitbucket(bitbucket, commit_or_tag) do
    [organization, repository | _] = String.split(bitbucket, "/")
    name = repository |> String.downcase()
    purl(["bitbucket", String.downcase(organization), name], commit_or_tag)
  end

  defp purl(type_namespace_name, version, qualifiers \\ []) do
    path =
      type_namespace_name
      |> Enum.map_join("/", &URI.encode/1)

    %URI{
      scheme: "pkg",
      path: "#{path}@#{URI.encode(version)}",
      query:
        case URI.encode_query(qualifiers) do
          "" -> nil
          query -> query
        end
    }
    |> to_string()
  end

  defp uuid() do
    [
      :crypto.strong_rand_bytes(4),
      :crypto.strong_rand_bytes(2),
      <<4::4, :crypto.strong_rand_bytes(2)::binary-size(12)-unit(1)>>,
      <<2::2, :crypto.strong_rand_bytes(2)::binary-size(14)-unit(1)>>,
      :crypto.strong_rand_bytes(6)
    ]
    |> Enum.map_join("", &Base.encode16(&1, case: :lower))
  end
end
