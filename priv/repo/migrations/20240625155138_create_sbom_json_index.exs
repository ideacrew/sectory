defmodule Sectory.Repo.Migrations.CreateSbomJsonIndex do
  use Ecto.Migration

  def up do
    execute("CREATE INDEX sbom_contents_data ON sbom_contents USING GIN(data)")
  end

  def down do
    execute("DROP INDEX sbom_contents_data")
  end
end
