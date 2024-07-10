defmodule HTTPSpec do
  @moduledoc """
  Provides implementation-independent HTTP-related structs.

  ## Why?

  Almost every HTTP client has its own abstractions for request and response.

  These abstractions are enough when solving problems with a particular HTTP
  client. But, when you are building a package involving HTTP and do not want
  to be tied to a specific HTTP client, these abstractions become limiting.

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

  """
end
