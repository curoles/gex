defmodule PingAlphavantage.CLI do

  def main(args \\ []) do
    args
    |> show_banner
    #|> parse_args
    #|> process
    do_http_request()
    IO.puts "Done."
  end

  defp show_banner(args) do
    IO.puts "Ping https://www.alphavantage.co"
    args
  end

  #defp parse_args(args) do
  #  {switches, filelist, _} = OptionParser.parse(args, switches: [dest: :string])
  #  {switches, filelist}
  #end

  #defp process({[],[]}) do
  #  IO.puts "No arguments given"
  #end

  #defp process({_,[]}) do
  #  IO.puts "No location of input directory given"
  #end

  #defp process({switches, filelist}) do
  #  [source | _] = filelist
  #  dest = switches[:dest]
  #  IO.puts "Source: '#{source}', destination: '#{dest}'"
  #  tasks = WalkDirectory.recursive(&Generator.visit_file/3, dest, source)
  #  Enum.each(tasks, fn _task ->
  #    receive do
  #      {:done, _ref} ->
  #        #IO.puts "Task finished"
  #        :ok
  #    end
  #  end)
  #end

  # https://github.com/edgurgel/httpoison
  defp do_http_request() do

    # The dependent applications are not started automatically at compile time.
    # You need to explicitly start HTTPoison before using it.
    HTTPoison.start()

    # https://hexdocs.pm/elixir/URI.html#encode_query/1
    query = %{
      "function" => "TIME_SERIES_INTRADAY", "symbol" => "MSFT",
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

PingAlphavantage.CLI.main(System.argv)
