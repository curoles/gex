defmodule LargeCSV do
  @moduledoc """
  Process large CSV files and strings with Stream.

  Author: Igor Lesik 2019

  References:

  - https://www.poeticoding.com/processing-large-csv-files-with-elixir-streams/
  - https://www.poeticoding.com/elixir-streams-to-process-large-http-responses-on-the-fly/
  - https://www.poeticoding.com/elixir-stream-and-large-http-responses-processing-text/
  - https://hexdocs.pm/nimble_csv/NimbleCSV.html
  - https://hexdocs.pm/flow/Flow.html
  - http://big-elephants.com/2016-12/http-streaming-in-elixir/
  - http://big-elephants.com/2016-12/http-streaming-in-elixir/
  """

  #@filename_ext "csv"

  @doc """
  Get stream of *lines* of the file.

  ## Parameters

    - filename: String that represents the path of the file.

  ## Examples

      iex> LargeCSV.file_strem("large.csv")
      TODO

  """
  def file_stream(filename) do
    # Return stream without opening the file.
    # Stream is made of lines ending with \n.
    File.stream!(filename)
  end

  @spec file_line_count(String.t()) :: non_neg_integer
  def file_line_count(filename) do
    file_stream(filename)
    |> Enum.count()
  end

  @doc """
  Return list of column values as lazy stream.

  Use Stream.filter(fn) to filter returned values.
  """
  def file_lines(filename, delimeter \\ ",") do
    file_stream(filename)
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split(&1, delimeter)) # create columns
  end
end
