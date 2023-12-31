defmodule BookStoreWeb.BookController do
  use BookStoreWeb, :controller

  alias BookStore.Books
  alias BookStore.Books.Book

  def index(conn, _params) do
    books = Books.all()

    conn
    |> json(books)
  end

  def show(conn, %{"id" => id}) do
    book = Books.read!(id)

    case book do
      %Book{} = book ->
        conn
        |> json(book)

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found"})
    end
  end

  def order(conn, %{"book_id" => book_id}) do
    status = Books.order(book_id)

    case status do
      :ok ->
        conn
        |> put_status(201)
        |> json(%{status: "Order placed"})

      :no_copies_available ->
        json(conn, %{status: "Not enough copies on hand to complete order"})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "Not found"})
    end
  end
end
