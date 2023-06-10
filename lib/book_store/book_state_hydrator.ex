defmodule BookStore.BookStateHydrator do
  use GenServer, restart: :transient

  require Logger

  alias BookStore.Books.Book
  alias BookStore.BookDynamicSupervisor

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__, timeout: 10_000)
  end

  @impl true
  def init(_) do
    Logger.info("#{inspect(Time.utc_now())} Starting Books process hydration")

    BookStore.Books.all()
    |> Enum.each(fn %Book{} = book ->
      BookDynamicSupervisor.add_book_to_supervisor(book)
    end)

    Logger.info("#{inspect(Time.utc_now())} Completed Books process hydration")

    # :ignore this signals to the supervisor that this process will not enter the process loop and that it has exited normally.
    # After the process hydration step is complete we no longer need this process so it is free to ride into the sunset
    :ignore
  end
end
