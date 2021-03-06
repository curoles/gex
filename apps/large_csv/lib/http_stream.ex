defmodule HTTPStream do
  @moduledoc """
  Get HTTP response as Stream.

  Author: Igor Lesik 2019

  Based on https://www.poeticoding.com/elixir-stream-and-large-http-responses-processing-text/

  ## Examples

      iex> url = "https://old.nasdaq.com/screening/companies-by-name.aspx?render=download" \\
      ...> |> HTTPStream.get \\
      ...> |> HTTPStream.lines \\
      ...> |> Enum.count
      STATUS: : 200
      HEADERS: : [
        {"Cache-Control", "private"},
        {"Content-Type", "application/text"},
        {"content-disposition", "attachment; filename=companylist.csv"},
        {"X-Frame-Options", "SAMEORIGIN"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-XSS-Protection", "1;mode=block"},
        {"Date", "Tue, 24 Dec 2019 02:32:31 GMT"},
        {"Transfer-Encoding", "chunked"},
        {"Connection", "keep-alive"},
        {"Connection", "Transfer-Encoding"},
        {"Set-Cookie",
        "NSC_W.TJUFEFGFOEFS.OBTEBR.443=ffffffffc3a08e3145525d5f4f58455e445a4a42378b;expires=Wed, 25-Dec-2019 02:32:31 GMT;path=/;secure;httponly"},
        {"Access-Control-Allow-Origin", "https://www.nasdaq.com"}
      ]
      END
      6997
  """

  @debug_enabled true

  @doc """
  Build a stream and return.

  ## Example

      iex> url = "https://old.nasdaq.com/screening/companies-by-name.aspx?render=download" \\
         > |> HTTPStream.get \\
         > |> Stream.run
      STATUS: : 200
      HEADERS: : [
        {"Cache-Control", "private"},
        {"Content-Type", "application/text"},
        {"content-disposition", "attachment; filename=companylist.csv"},
        {"X-Frame-Options", "SAMEORIGIN"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-XSS-Protection", "1;mode=block"},
        {"Date", "Mon, 23 Dec 2019 07:17:57 GMT"},
        {"Transfer-Encoding", "chunked"},
        {"Connection", "keep-alive"},
        {"Connection", "Transfer-Encoding"},
        {"Set-Cookie", "NSC_W.TJUFEFGFOEFS.OBTEBR.443=ffffffffc3a0f73145525d5f4f58455e445a4a42378b;expires=Tue, 24-Dec-2019 07:17:57 GMT;path=/;secure;httponly"},
        {"Access-Control-Allow-Origin", "https://www.nasdaq.com"}
      ]
      END
      :ok
  """
  def get(url, emit_end \\ false) do
    Stream.resource(
      ############## start ################
      fn ->
        stream_start(url)
      end,
      ############## next ##################
      fn %HTTPoison.AsyncResponse{}=resp -> stream_next(resp, emit_end)
        {:end, resp}                     -> {:halt, resp}
      end,
      ############## after #################
      fn %HTTPoison.AsyncResponse{id: id} ->
        stream_after(id)
      end
    )
  end

  @doc private: """
  Start the enumeration with making an async HTTP request.

  Returns immediately a `%HTTPoison.AsyncResponse{id: #Reference<...>}` struct,
  which is then passed to `next_fun`.
  """
  defp stream_start(url) do
    HTTPoison.get!(
      url,
      %{},
      [stream_to: self(), async: :once]
    )
  end

  defp stream_after(id) do
    with @debug_enabled do IO.puts("END") end
    :hackney.stop_async(id)
  end

  @doc private: """
  Handle next chunk of data from async http response.

  Must return a tuple, this can be `{[...], resp}` when we want to pass elements to the pipeline,
  or `{:halt, resp}` when we want to stop the enumeration.
  """
  defp stream_next(%HTTPoison.AsyncResponse{id: id}=resp, emit_end) do
    handle_async_resp(resp, id, emit_end)
  end

  defp handle_async_resp(resp, id, emit_end) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code}->
        with @debug_enabled do IO.inspect(code, label: "STATUS: ") end
        HTTPoison.stream_next(resp)
        {[], resp}
      %HTTPoison.AsyncHeaders{id: ^id, headers: headers}->
        with @debug_enabled do IO.inspect(headers, label: "HEADERS: ") end
        HTTPoison.stream_next(resp)
        {[], resp}
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk}->
        HTTPoison.stream_next(resp)
        {[chunk], resp}
      %HTTPoison.AsyncEnd{id: ^id}->
        if emit_end do
          {[:end], {:end, resp}}
        else
          {:halt, resp}
        end
    after
      5_000 -> raise "receive timeout"
    end
  end


  @doc """
  Transform stream of string chunks into stream of lines,
  where a line is a string ending with `\\n`.

  The idea: We split the chunk into lines and the last element of the list
  becomes the accumulator, which is concatenated to the next chunk.

  Return a tuple containing a new stream with the new accumulator
  or a tuple with :halt as first element and the accumulator as second.

  ## Examples

      iex> ["767\\n13","8\\n-701\\n98\\n-","504\\n22😋", :end] \\
      ...> |> HTTPStream.lines() \\
      ...> |> Enum.each(&IO.inspect/1)
      "767"
      "138"
      "-701"
      "98"
      "-504"
      "22😋"
      :ok

      iex> ["767\\n13","8\\n-701\\n98\\n-","504\\n22", :end] \\
      ...> |> HTTPStream.lines() \\
      ...> |> Enum.count()
      6
  """
  @spec lines(Enumerable.t()) :: (any, any -> any)
  def lines(enum) do
    enum
    |> Stream.transform("", fn
      # got EndOfStream marker
      :end, acc ->
        {[acc], # last part of data
         ""     # empty accum
        }
      # got new chunk and accumulator with tail from prev chunk
      chunk, acc ->
        lines = String.split(acc <> chunk, "\n")
        {Enum.drop(lines, -1), # drop the tail, return list of lines
         List.last(lines)      # tail, new accumulator
        }
    end)
  end

end
