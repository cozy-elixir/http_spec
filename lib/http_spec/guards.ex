defmodule HTTPSpec.Guards do
  @moduledoc false

  alias HTTPSpec.Request
  alias HTTPSpec.Response

  defguard is_message(value) when is_struct(value, Request) or is_struct(value, Response)
end
