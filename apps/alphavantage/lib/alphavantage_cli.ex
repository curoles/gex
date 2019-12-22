defmodule Alphavantage.CLI do

  def main(args \\ []) do
    args
    |> show_banner
    |> parse_args
    |> process
    IO.puts "Done."
  end

  defp show_banner(args) do
    IO.puts "Test API https://www.alphavantage.co"
    args
  end

  # https://hexdocs.pm/elixir/OptionParser.html
  #
  defp parse_args(args) do
    # Options are defined with Keyword list:
    # [switches: keyword(), strict: keyword(), aliases: keyword()]
    options = [strict: [letter: :string]]
    {switches, cmds, _} = OptionParser.parse(args, options)
    # OptionParser returned tuple:
    # {list of parsed switches, list of the remaining arguments, list of invalid options}
    {cmds, switches}
  end

  defp process({[],[]}) do
    IO.puts "No arguments given. Usage:"
    IO.puts "alphavantage get"
    IO.puts "alphavantage list --letter"
  end

  #defp process({_,[]}) do
  #  IO.puts "No location of input directory given"
  #end

  defp process({cmds, switches}) do
    [cmd | _] = cmds
    case cmd do
      "get" ->
        do_http_request()
      "list" ->
        show_symbols(switches)
      _ ->
        IO.puts "unknown command " <> cmd
    end
  end

  # https://github.com/edgurgel/httpoison
  defp do_http_request() do

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

  defp show_symbols(switches) do
    CompanyList.all(switches[:letter])
  end

end

Alphavantage.CLI.main(System.argv)
