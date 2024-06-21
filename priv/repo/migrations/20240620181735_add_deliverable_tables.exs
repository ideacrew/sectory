defmodule Sectory.Repo.Migrations.AddDeliverableTables do
  use Ecto.Migration

  def change do
    create table("deliverables") do
      add :name, :string, size: 256, null: false
      timestamps()
    end

    create index(:deliverables, ["name"])

    create table("deliverable_versions") do
      add :version, :string, size: 128, null: true
      add :git_sha, :string, size: 128, null: true
      add :deliverable_id, references(:deliverables)
      timestamps()
    end
    create index(:deliverable_versions, ["deliverable_id"])
    create index(:deliverable_versions, ["version", "git_sha"])

    create table("version_sboms") do
      add :deliverable_version_id, references(:deliverable_versions)
      add :name, :string, size: 256, null: false
      timestamps()
    end

    create index(:version_sboms, ["deliverable_version_id"])
    create index(:version_sboms, ["name"])

    create table("sbom_contents") do
      add :version_sbom_id, references(:version_sboms)
      add :data, :map, default: %{}
      timestamps()
    end

    create index(:sbom_contents, [:version_sbom_id])
  end
end
