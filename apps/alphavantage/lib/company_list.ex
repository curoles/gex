defmodule CompanyList do
  @moduledoc """
  CompanyList module has functions to:
  - get a list of all companies trading at NYSE and
  - search through the list.
  """

  @doc """
  Get list of all NYSE stock exchange symbols/companies.

  ## Examples

      iex> CompanyList.all("J", "nyse")
      "Symbol","Name","LastSale","MarketCap","IPOyear","Sector","industry","Summary Quote",
      "JPM","J P Morgan Chase & Co","137.24","$430.45B","n/a","Finance","Major Banks","https://old.nasdaq.com/symbol/jpm",
  """
  def all(letter \\ "", exchange \\ "") do
    HTTPoison.start()

    query = %{"exchange" => exchange, "render" => "download", "letter" => letter}
    url = "https://old.nasdaq.com/screening/companies-by-name.aspx?" <> URI.encode_query(query)

    options = [recv_timeout: 10000]

    response = HTTPoison.get(url, [], options)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        #IO.puts body
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        #IO.puts "Not found :("
        {:error, :notfound}
      {:error, %HTTPoison.Error{reason: reason}} ->
        #IO.inspect reason
        {:error, reason}
    end
  end

  @spec find_symbol(String.t(), String.t()) :: {:ok|:error, [String.t()]}
  def find_symbol(symbol_name, exchange \\ "") do
    symbols = all(String.first(symbol_name), exchange)
    case symbols do
      {:error, _} ->
        {:error, []}
      {:ok, csv_symbols} ->
        csv_symbols
        |> String.split(~r/(\r?\n|\r)/, trim: true)
        |> Stream.map(&(&1))
        |> CSV.decode(headers: :false)
        |> Enum.filter(fn {:ok, x} -> String.starts_with?(Enum.at(x,0), symbol_name) end)
        |> Enum.take(1)
    end
  end

end
