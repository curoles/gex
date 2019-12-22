defmodule Alphavantage do
  @moduledoc """
  Request stock exchange information.
  """

  @doc """
  Query information.

  Using [httpoison](https://github.com/edgurgel/httpoison)
  """
  @spec query(map) :: {:error, any} | {:ok, String.t()}
  def query(query) do

    # The dependent applications are not started automatically at compile time.
    # You need to explicitly start HTTPoison before using it.
    HTTPoison.start()

    url = base_url() <> "/query?" <> URI.encode_query(query)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404 Not found :("}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp base_url do
    "https://www.alphavantage.co"
  end

  @spec search(String.t(), String.t()) :: {:error, any} | {:ok, String.t()}
  def search(keyword, apikey) do
    query = %{"function" => "SYMBOL_SEARCH", "keywords" => keyword, "apikey" => apikey}
    query(query)
  end

  @spec endpoint(String.t(), String.t()) :: {:error, any} | {:ok, String.t()}
  def endpoint(symbol, apikey) do
    query = %{"function" => "GLOBAL_QUOTE", "symbol" => symbol, "apikey" => apikey}
    query(query)
  end

  @spec get_env_apikey :: String.t()
  def get_env_apikey do
    System.get_env("ALPHA_VANTAGE_ACESS_KEY", "demo")
  end
end
