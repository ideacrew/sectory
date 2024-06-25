defmodule Sectory.Repo.Migrations.AddVersionArtifacts do
  use Ecto.Migration

  def change do
    create table("file_artifacts") do
      add :size, :integer, null: false
      add :sha256, :string, size: 512, null: false
      add :sha384, :string, size: 768, null: false
      add :sha512, :string, size: 1024, null: false
      timestamps()
    end

    create index(:file_artifacts, ["size", "sha256", "sha384", "sha512"])

    create table("version_artifacts") do
      add :deliverable_version_id, references(:deliverable_versions), null: false
      add :file_artifact_id, references(:file_artifacts), null: false
      add :original_filename, :string, null: false, size: 512
      timestamps()
    end

    create index(:version_artifacts, ["deliverable_version_id"])
    create index(:version_artifacts, ["file_artifact_id"])
    create index(:version_artifacts, ["original_filename"])

    create table("file_artifact_contents") do
      add :file_artifact_id, references(:file_artifacts), null: false
      add :content, :binary
      timestamps()
    end

    create index(:file_artifact_contents, ["file_artifact_id"])
  end
end
