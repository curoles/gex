defmodule Alphavantage.CLI do

  def main(args \\ []) do
    args
    |> show_banner
    |> parse_args
    |> process
    #IO.puts "Done."
  end

  defp show_banner(args) do
    #IO.puts "Test API https://www.alphavantage.co"
    args
  end

  # https://hexdocs.pm/elixir/OptionParser.html
  #
  defp parse_args(args) do
    # Options are defined with Keyword list:
    # [switches: keyword(), strict: keyword(), aliases: keyword()]
    options = [
      strict: [letter: :string, symbol: :string, apikey: :string, interval: :integer]
    ]
    {switches, cmds, _} = OptionParser.parse(args, options)
    # OptionParser returned tuple:
    # {list of parsed switches, list of the remaining arguments, list of invalid options}
    {cmds, switches}
  end

  defp process({[],[]}) do
    IO.puts "No arguments given. Usage:"
    IO.puts "  alphavantage get --symbol SYM --apikey KEY [--interval 1|5|15|30|60]"
    IO.puts "  alphavantage list [--letter <L>]"
    IO.puts "  alphavantage find SYM"
  end

  #defp process({_,[]}) do
  #  IO.puts "No location of input directory given"
  #end

  defp process({cmds, switches}) do
    [cmd | _] = cmds
    case cmd do
      "get" ->
        request_info(switches)
      "list" ->
        show_symbols(switches)
      "find" ->
        if Enum.count(cmds) > 1 do
          find_symbol(Enum.at(cmds,1))
        else
          IO.puts "provide symbol name"
        end
      _ ->
        IO.puts "unknown command " <> cmd
    end
  end

  # https://github.com/edgurgel/httpoison
  defp request_info(switches) do

    apikey = switches[:apikey]

    symbol_name = switches[:symbol]
    find_symbol(symbol_name)

    # The dependent applications are not started automatically at compile time.
    # You need to explicitly start HTTPoison before using it.
    HTTPoison.start()

    # https://hexdocs.pm/elixir/URI.html#encode_query/1
    query = %{
      "function" => "TIME_SERIES_INTRADAY", "symbol" => symbol_name,
      "interval" => "60min", "apikey" => apikey}
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
    result = CompanyList.all(switches[:letter])
    case result do
      {:ok, symbols} ->
        IO.puts symbols
      {:error, _} ->
        IO.puts "failed to get data"
    end
  end

  defp find_symbol(symbol_name) do
    result = CompanyList.find_symbol(symbol_name, "")
    case result do
      [ok: description] ->
        IO.puts "Symbol:     #{Enum.at(description,0)}"
        IO.puts "Company:    #{Enum.at(description,1)}"
        IO.puts "Price:      #{Enum.at(description,2)}"
        IO.puts "Market Cap: #{Enum.at(description,3)}"
        IO.puts "Sector:     #{Enum.at(description,5)}, #{Enum.at(description,6)}"
      [error: _] ->
        IO.puts "can't find symbol"
    end
  end

end

Alphavantage.CLI.main(System.argv)
