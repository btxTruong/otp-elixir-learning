# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BookStore.Repo.insert!(%BookStore.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias BookStore.Books.Book
alias BookStore.Repo

{book_data, _} = Code.eval_file(Path.join([__DIR__, "..", "..", "books_data.exs"]))

book_data
|> Enum.filter(fn %{authors: authors, description: description, title: title} ->
  !Enum.empty?(authors) && String.trim(description) !== "" && String.trim(title) !== ""
end)
|> Enum.map(fn
  %{price: :not_for_sale} = book ->
    book
    |> Map.put(:price, "N/A")
    |> Map.put(:quantity, 0)

  book ->
    book
    |> Map.put(:quantity, 5_000)
end)
|> Enum.each(fn book ->
  %Book{}
  |> Book.changeset(book)
  |> Repo.insert!()
end)
