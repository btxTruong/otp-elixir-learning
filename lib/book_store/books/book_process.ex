defmodule BookStore.Books.BookProcess do
  use GenServer, restart: :transient

  require Logger

  alias BookStore.Repo
  alias BookStore.Books.Book
  alias Ecto.Changeset

  def start_link(%Book{} = book) do
    GenServer.start_link(
      __MODULE__,
      book,
      name: {:via, Registry, {BookStore.BookRegistry, book.id}}
    )
  end

  @impl true
  def init(%Book{} = book) do
    {:ok, book}
  end

  @impl true
  def handle_call(:read, _from, %Book{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:update, attrs}, _from, %Book{} = state) do
    state
    |> update_book(attrs)
    |> case do
      {:ok, %Book{} = updated_book} ->
        {:reply, updated_book, updated_book, {:continue, :persist_book_changes}}

      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:order_copy, _from, %Book{quantity: 0} = state) do
    {:reply, :no_copies_available, state}
  end

  @impl true
  def handle_call(:order_copy, _from, %Book{quantity: quantity} = state) do
    state
    |> update_book(%{quantity: quantity - 1})
    |> case do
      {%Book{} = updated_book, changeset} ->
        {:reply, :ok, updated_book, {:continue, {:persist_book_changes, changeset}}}

      error ->
        {:reply, error, state}
    end
  end

  #  In our case our handle_continue/2 function that matches on {:persist_book_changes, changeset} simply writes the state to the database. While this may seen trivial, it has very important implications. What this does is ensure that our HTTP requests coming in are serviced out-of-band from our database interactions. This means that requests can be serviced orders of magnitude faster given that there are no external resources that need to be called for the purposes of servicing the HTTP request. In addition, we are able to maintain database state parity given that our handle_continue/2 callback ensures that it is called immediately after a state change. All other requests in the process mailbox are deferred until the database is updated.
  @impl true
  def handle_continue({:persist_book_changes, changeset}, state) do
    Repo.update(changeset)

    {:noreply, state}
  end

  defp update_book(book, attrs) do
    book
    |> Book.changeset(attrs)
    |> case do
      %Changeset{valid?: true} = changeset ->
        updated_book = Changeset.apply_changes(changeset)
        {updated_book, changeset}

      error_changeset ->
        {:error, error_changeset}
    end
  end
end
