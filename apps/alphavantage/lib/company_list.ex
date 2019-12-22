defmodule CompanyList do
  @moduledoc """
  CompanyList module has functions to:
  - get a list of all companies trading at NYSE and
  - search through the list.
  """

  @doc """
  Get list of all NYSE stock exchange symbols/companies.

  ## Examples

      iex> CompanyList.all("J")
      "Symbol","Name","LastSale","MarketCap","IPOyear","Sector","industry","Summary Quote",
      "JPM","J P Morgan Chase & Co","137.24","$430.45B","n/a","Finance","Major Banks","https://old.nasdaq.com/symbol/jpm",
  """
  def all(letter \\ "") do
    HTTPoison.start()

    query = %{"exchange" => "nyse", "render" => "download", "letter" => letter}
    url = "https://old.nasdaq.com/screening/companies-by-name.aspx?" <> URI.encode_query(query)

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
