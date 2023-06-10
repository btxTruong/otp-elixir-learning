defmodule BookStore.BookRegistry do
  @moduledoc false

  def child_spec do
    Registry.child_spec(
      key: :unique,
      name: __MODULE__,
      partition: System.schedulers_online()
    )
  end

  def lookup_book(book_id) do
    case Registry.lookup(__MODULE__, book_id) do
      [{book_id, _}] -> {:ok, book_id}
      [] -> {:error, :not_found}
    end
  end
end
