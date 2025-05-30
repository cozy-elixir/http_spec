defmodule HTTPSpec do
  @moduledoc """
  Provides implementation-independent HTTP-related structs.

  ## Why?

  Almost every HTTP client has its own abstractions for request and response.
  These abstractions are enough when solving problems with a particular HTTP
  client. But, when you are building a package involving HTTP and do not want
  to be tied to a specific HTTP client, these abstractions become limiting.

  HTTP clients come and go, but HTTP standards endure forever. It's better to
  build around something that is almost unchanging, rather than something
  that frequently changes.

  This package try to provide implementation-independent HTTP-related structs.
  With these structs, you can build things involving HTTP, but no actual HTTP
  request-response handling is required.

  ## Structs

    * `HTTPSpec.Request`
    * `HTTPSpec.Response`

  ## Usage

  Build a request struct:

      HTTPSpec.Request.new(options)
      HTTPSpec.Request.new!(options)

  Build a response struct:

      HTTPSpec.Response.new(options)
      HTTPSpec.Response.new!(options)

  Check out their docs for more available functionalities.
  """

  alias HTTPSpec.Request
  alias HTTPSpec.Response

  @type message :: Request.t() | Response.t()
  @type field :: {name :: String.t(), value :: String.t()}
end
