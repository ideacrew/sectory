# frozen_string_literal: true

require "sbom_on_rails"

sha = ENV["COMMIT_SHA"] || "UNKNOWN_SHA"
project_name = "sectory"

component_def = SbomOnRails::Sbom::ComponentDefinition.new(
  project_name,
  sha,
  { github: "https://github.com/ideacrew/sectory" }
)

manifest = SbomOnRails::Manifest::ManifestFile.new(
  File.join(
    File.dirname(__FILE__),
    "manifest.yaml"
  )
)

File.open(
  File.join(
    File.dirname(__FILE__),
    "../sectory-alpine.sbom"
  ),
  "wb"
) do |f|
  begin
    f.puts manifest.execute(component_def)
  rescue Exception => e
    raise e.message.inspect
  end
end
