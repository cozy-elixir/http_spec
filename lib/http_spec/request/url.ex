defmodule HTTPSpec.Request.URL do
  @moduledoc """
  Helpers to handle URL.
  """

  @doc """
  Parses an URL.

  ## Examples

      URL.parse("http://www.example.com/?say=hi#mom")

      # Returns:
      #
      # %{
      #    scheme: :http,
      #    host: "www.example.com",
      #    port: 80,
      #    path: "/",
      #    query: "say=hi",
      #    fragment: "mom"
      #  }

  """
  @spec parse(String.t()) :: map()
  def parse("http://" <> _ = url), do: do_parse(url)
  def parse("https://" <> _ = url), do: do_parse(url)
  def parse(_url), do: raise(RuntimeError, "only http:// or https:// address is supported")

  defp do_parse(url) do
    %{
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      query: query,
      fragment: fragment
    } = URI.parse(url)

    %{
      scheme: String.to_atom(scheme),
      host: host,
      port: port,
      path: path,
      query: query,
      fragment: fragment
    }
  end

  # used as custom type of nimble_options
  @doc false
  def type(value) do
    try do
      {:ok, parse(value)}
    rescue
      error in [RuntimeError] ->
        {:error, error.message}
    end
  end
end
