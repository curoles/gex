defmodule Alphavantage.CLI do

  def main(args \\ []) do
    args
    |> show_banner
    |> parse_args
    |> process
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
    IO.puts "  gex get --symbol SYM --apikey KEY [--interval 1|5|15|30|60]"
    IO.puts "  gex list [--letter <L>]"
    IO.puts "  gex find SYM"
    IO.puts "  gex search KEYWORD --apikey KEY"
  end

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
      "search" ->
        if Enum.count(cmds) > 1 do
          search_keyword(Enum.at(cmds,1), switches)
        else
          IO.puts "provide keyword"
        end
      _ ->
        IO.puts "unknown command " <> cmd
    end
  end

  defp request_info(switches) do

    apikey = switches[:apikey] || Alphavantage.get_env_apikey()
    symbol_name = switches[:symbol]

    find_symbol(symbol_name)

    endpoint_result = Alphavantage.endpoint(symbol_name, apikey)
    case endpoint_result do
      {:ok, endpoint} ->
        IO.puts endpoint
    end

    intraday_result = Alphavantage.intraday(symbol_name, 60, apikey)
    case intraday_result do
      {:ok, json_intraday} ->
        {_status, intraday} = JSON.decode(json_intraday)
        _time_series = intraday["Time Series (60min)"]
        |> Enum.take(24)
        |> Enum.each(fn ts ->
          {_time, data} = ts
          IO.puts data["4. close"]
        end)
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
      [] ->
        IO.puts "can't find symbol"
    end
  end

  defp search_keyword(keyword, switches) do
    apikey = switches[:apikey] || Alphavantage.get_env_apikey()
    result = Alphavantage.search(keyword, apikey)
    case result do
      {:ok, body} ->
        IO.puts body
      {:error, _} ->
        IO.puts "found nothing"
    end
  end
end

Alphavantage.CLI.main(System.argv)
