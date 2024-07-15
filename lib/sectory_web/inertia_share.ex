defmodule SectoryWeb.InertiaShare do
  use SectoryWeb, :controller

  @moduledoc """
  Shared properties for Inertia Components.
  """

  def init(default), do: default

  def call(conn, _) do
    conn
    |> assign_prop(
      :mainNavLinks, build_main_nav_links()
      )
    |> assign_current_user()

  end

  defp assign_current_user(conn) do
    if conn.assigns[:current_user] do
      assign_prop(
        conn,
        :current_user,
        %{
          email: conn.assigns[:current_user].email
        }
      )
    else
      assign_prop(
        conn,
        :current_user,
        nil
      )
    end
  end

  defp build_main_nav_links() do
    %{
      homeUrl: ~p"/",
      deliverablesUrl: ~p"/deliverables",
      vulnerabilityAnalysesUrl: ~p"/vulnerability_analyses",
      settingsUrl: ~p"/users/settings",
      logoutUrl: ~p"/users/log_out"
    }
  end
end
