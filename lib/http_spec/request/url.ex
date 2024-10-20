defmodule HTTPSpec.Request.URL do
  @moduledoc """
  Helpers for handling URL.
  """

  defmodule ParseError do
    @moduledoc """
    An error that is returned (or raised) when failed to parse a string as URL.
    """

    defexception [:message]

    @type t() :: %__MODULE__{}
  end

  defstruct [:scheme, :host, :port, :path, :query, :fragment]

  @type t :: %__MODULE__{
          scheme: :http | :https,
          host: nil | binary(),
          port: nil | :inet.port_number(),
          path: nil | binary(),
          query: nil | binary(),
          fragment: nil | binary()
        }

  @doc """
  Parses an URL.

  ## Examples

      iex> HTTPSpec.Request.URL.parse("http://www.example.com/?say=hi#mom")
      {:ok,
       %HTTPSpec.Request.URL{
         scheme: :http,
         host: "www.example.com",
         port: 80,
         path: "/",
         query: "say=hi",
         fragment: "mom"
       }}

  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, ParseError.t()}
  def parse("http://" <> _ = url), do: do_parse(url)
  def parse("https://" <> _ = url), do: do_parse(url)

  def parse(_),
    do: {:error, %ParseError{message: "only http:// or https:// address is supported"}}

  @doc """
  Bang version of `parse/1`.
  """
  @spec parse!(String.t()) :: t()
  def parse!(url) do
    case parse(url) do
      {:ok, t} -> t
      {:error, exception} -> raise exception
    end
  end

  defp do_parse(url) do
    %{
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      query: query,
      fragment: fragment
    } = URI.parse(url)

    {:ok,
     %__MODULE__{
       scheme: String.to_atom(scheme),
       host: host,
       port: port,
       path: path,
       query: query,
       fragment: fragment
     }}
  end

  # used as custom type of nimble_options
  @doc false
  def type(value) do
    try do
      {:ok, parse!(value)}
    rescue
      error in [ParseError] ->
        {:error, error.message}
    end
  end
end
