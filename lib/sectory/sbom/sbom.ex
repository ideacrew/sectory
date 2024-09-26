defmodule Sectory.Sbom.Sbom do
  @moduledoc """
  Extract data from an SBOM structure.
  """

  def components(sbom) do
    component_lens = Lens.key("components")
                     |> Lens.all()
    Lens.to_list(component_lens, sbom)
  end
end
