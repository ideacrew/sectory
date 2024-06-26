defmodule SectoryWeb.Router do
  use SectoryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SectoryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Inertia.Plug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SectoryWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/pages/home", PageController, :home
    resources "/deliverables", DeliverableController, only: [:index, :show]
    resources "/deliverable_versions", DeliverableVersionController, only: [:show]
    resources "/version_sboms", VersionSbomController, only: [:show]
    get "/exports/vulnerability_analyses", ExportsController, :vulnerability_analyses, as: :vulnerability_analyses
    get "/exports/sbom_and_analyses", ExportsController, :sbom_and_analyses, as: :sbom_and_analyses
    scope "/version_sboms" do
      get "/:id/analyzed", VersionSbomController, :analyzed
    end
    scope "/version_artifacts" do
      get "/:id/download", VersionArtifactController, :download
    end
    resources "/vulnerability_analyses", VulnerabilityAnalysisController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", SectoryWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:sectory, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SectoryWeb.Telemetry
    end
  end
end
