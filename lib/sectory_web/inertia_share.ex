defmodule SectoryWeb.InertiaShare do
  use SectoryWeb, :controller

  @moduledoc """
  Shared properties for Inertia Components.
  """

  def init(default), do: default

  def call(conn, _) do
    assign_prop(
      conn, :mainNavLinks, build_main_nav_links()
    )
  end

  defp build_main_nav_links() do
    %{
      homeUrl: ~p"/",
      deliverablesUrl: ~p"/deliverables",
      vulnerabilityAnalysesUrl: ~p"/vulnerability_analyses"
    }
  end
end
