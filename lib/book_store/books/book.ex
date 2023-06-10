defmodule BookStore.Books.Book do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @derive {Jason.Encoder, only: ~w(title authors description price quantity)a}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "books" do
    field :title, :string
    field :authors, {:array, :string}
    field :description, :string
    field :price, :string
    field :quantity, :integer

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = book, attrs \\ %{}) do
    book
    |> cast(attrs, [:title, :authors, :description, :price, :quantity])
    |> validate_required([:title, :authors, :description, :price, :quantity])
  end

end
