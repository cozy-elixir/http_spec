defmodule HTTPSpec.Request do
  @moduledoc """
  A struct for describing HTTP request.
  """

  @enforce_keys [:scheme, :host, :port, :method, :path, :headers, :body, :query]

  defstruct [
    :scheme,
    :host,
    :port,
    :method,
    :path,
    :headers,
    :body,
    :query
  ]

  @type scheme :: :http | :https
  @type host :: String.t() | nil
  @type method :: atom() | String.t()
  @type path :: String.t()
  @type headers :: [{header_name :: String.t(), header_value :: String.t()}]
  @type body :: iodata() | nil
  @type query :: String.t() | nil

  @type t :: %__MODULE__{
          scheme: scheme(),
          host: host(),
          port: :inet.port_number(),
          method: method(),
          path: path(),
          headers: headers(),
          body: body(),
          query: query()
        }
end
