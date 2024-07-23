defmodule SectoryWeb.InertiaShare do
  use SectoryWeb, :controller

  @moduledoc """
  Shared properties for Inertia Components.
  """

  def init(default), do: default

  def call(conn, _) do
    conn
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
end
