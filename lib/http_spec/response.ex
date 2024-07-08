defmodule HTTPSpec.Response do
  @moduledoc """
  A struct for describing HTTP response.
  """

  defstruct [
    :status,
    body: "",
    headers: [],
    trailers: []
  ]

  @type status :: non_neg_integer()
  @type body :: binary()
  @type headers :: [{header_name :: String.t(), header_value :: String.t()}]

  @type t :: %__MODULE__{
          status: status(),
          body: binary(),
          headers: headers(),
          trailers: headers()
        }
end
