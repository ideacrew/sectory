defmodule SectoryWeb.Router do
  use SectoryWeb, :router

  import SectoryWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SectoryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :browser_lite do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SectoryWeb.Layouts, :root}
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug SectoryWeb.InertiaShare
    plug Inertia.Plug
  end

  pipeline :inertia do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SectoryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug SectoryWeb.InertiaShare
    plug Inertia.Plug
  end

  pipeline :print_report do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {SectoryWeb.Layouts, :print_report}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SectoryWeb do
    pipe_through [:inertia, :require_authenticated_user]

    get "/", HomeController, :index
    get "/pages/home", PageController, :home
    resources "/deliverables", DeliverableController, only: [:index, :show] do
      resources "/deliverable_versions", DeliverableVersionController, only: [:new, :create]
    end
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
    resources "/vulnerability_analyses", VulnerabilityAnalysisController, only: [:new, :create, :edit, :update, :index]
  end

  scope "/", SectoryWeb do
    pipe_through [:print_report, :require_authenticated_user]

    resources "/sbom_vulnerability_reports", SbomVulnerabilityReportController, only: [:show]
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

  ## Authentication routes

  scope "/", SectoryWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SectoryWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SectoryWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SectoryWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", SectoryWeb do
    pipe_through [:browser_lite]
    delete "/users/log_out", UserSessionController, :delete
  end

  scope "/", SectoryWeb do
    pipe_through [:browser]

    get "/users/error", UserSessionController, :error

    live_session :current_user,
      on_mount: [{SectoryWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
