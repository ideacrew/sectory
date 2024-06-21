defmodule Sectory.Records.Deliverable do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deliverables" do
    field :name, :string
    has_many :deliverable_versions, Sectory.Records.DeliverableVersion
    timestamps()
  end

  def new(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(deliverable, params \\ %{}) do
    deliverable
      |> cast(params, [:name])
      |> validate_required([:name])
      |> validate_length(:name, max: 256)
  end
end
