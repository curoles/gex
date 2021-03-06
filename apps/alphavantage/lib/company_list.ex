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

    query = %{"exchange" => exchange, "render" => "download", "letter" => letter,
      "sortname" => "marketcap", "sorttype" => 1}
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

  @doc """
  Find stock exchange symbol and return its description.

  ## Examples

      iex> CompanyList.find_symbol("IBM", "nasdaq")
      [
        ok: ["IBM", "International Business Machines Corporation", "135.59",
             "$120.08B", "n/a", "Technology", "Computer Manufacturing",
             "https://old.nasdaq.com/symbol/ibm"]
      ]
  """
  @spec find_symbol(String.t(), String.t()) :: {:ok|:error, [String.t()]}
  def find_symbol(symbol_name, exchange \\ "") do
    symbols = all("", exchange)
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


  def top(maxsize \\ 1000, letter \\ "", exchange \\ "") do
    result = all(letter, exchange)
    case result do
      {:ok, symbols} ->
        symbols
        |> String.split(~r/(\r?\n|\r)/, trim: true)
        |> CSV.decode(headers: :true)
        |> Enum.take(maxsize)
      {:error, _} ->
        {:error, []}
    end
  end
end
