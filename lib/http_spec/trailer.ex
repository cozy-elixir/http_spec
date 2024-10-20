defmodule HTTPSpec.Trailer do
  @moduledoc """
  Helpers to handle trailers.
  """

  alias HTTPSpec.Request
  alias HTTPSpec.Response

  @type trailers :: [HTTPSpec.field()]
  @type msg :: Request.t() | Response.t()
end
