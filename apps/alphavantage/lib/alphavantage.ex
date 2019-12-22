defmodule Alphavantage do
  @moduledoc """
  Request stock exchange information.
  """

  @doc """
  Request information.

  Using [httpoison](https://github.com/edgurgel/httpoison)
  """
  def request() do

    # The dependent applications are not started automatically at compile time.
    # You need to explicitly start HTTPoison before using it.
    HTTPoison.start()

    # https://hexdocs.pm/elixir/URI.html#encode_query/1
    query = %{
      "function" => "TIME_SERIES_INTRADAY", "symbol" => "IBM",
      "interval" => "5min", "apikey" => "demo"}
    url = "https://www.alphavantage.co/query?" <> URI.encode_query(query)
    IO.puts url

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end
