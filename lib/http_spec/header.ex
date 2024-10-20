defmodule HTTPSpec.Header do
  @moduledoc """
  Helpers to handle headers.
  """

  alias HTTPSpec.Request
  alias HTTPSpec.Response

  @type headers :: [HTTPSpec.field()]
  @type msg :: Request.t() | Response.t()

  @doc """
  Returns the values of the header specified by `name`.

  ## Examples

      iex> HTTPSpec.Header.get_header(request, "accept")
      ["application/json"]
      iex> HTTPSpec.Header.get_header(requset, "x-unknown")
      []

  """
  @spec get_header(msg(), binary()) :: [binary()]
  def get_header(msg, name)
      when (is_struct(msg, Request) or is_struct(msg, Response)) and
             is_binary(name) do
    name = ensure_header_downcase(name)

    for {^name, value} <- msg.headers do
      value
    end
  end

  @doc """
  Puts the given `value` under `name`.

  If the header was previously set, its value is overwritten.

  ## Examples

      iex> HTTPSpec.Header.get_header(request, "accept")
      []
      iex> request = Request.put_header(request, "accept", "application/json")
      iex> HTTPSpec.Header.get_header(request, "accept")
      ["application/json"]

  """
  @spec put_header(msg(), binary(), binary()) :: msg()
  def put_header(msg, name, value)
      when (is_struct(msg, Request) or is_struct(msg, Response)) and
             is_binary(name) and
             is_binary(value) do
    name = ensure_header_downcase(name)
    %{msg | headers: List.keystore(msg.headers, name, 0, {name, value})}
  end

  @doc """
  Puts the given `value` under `name` unless already present.

  See `put_header/3` for more information.

  ## Examples

      iex> request =
      ...>   request
      ...>   |> HTTPSpec.Header.put_new_header("accept", "application/json")
      ...>   |> HTTPSpec.Header.put_new_header("accept", "text/html")
      iex> HTTPSpec.Header.get_header(request, "accept")
      ["application/json"]

  """
  @spec put_new_header(msg(), binary(), binary()) :: msg()
  def put_new_header(msg, name, value)
      when (is_struct(msg, Request) or is_struct(msg, Response)) and
             is_binary(name) and
             is_binary(value) do
    case get_header(msg, name) do
      [] -> put_header(msg, name, value)
      _ -> msg
    end
  end

  @doc """
  Lazy version of `put_new_header/3`.
  """
  @spec put_new_lazy_header(msg(), binary(), (-> binary()) | (msg() -> binary())) :: msg()
  def put_new_lazy_header(msg, name, fun)
      when (is_struct(msg, Request) or is_struct(msg, Response)) and
             is_binary(name) and
             is_function(fun, 0) do
    case get_header(msg, name) do
      [] ->
        value = apply(fun, [])
        put_header(msg, name, value)

      _ ->
        msg
    end
  end

  def put_new_lazy_header(msg, name, fun)
      when (is_struct(msg, Request) or is_struct(msg, Response)) and
             is_binary(name) and
             is_function(fun, 1) do
    case get_header(msg, name) do
      [] ->
        value = apply(fun, [msg])
        put_header(msg, name, value)

      _ ->
        msg
    end
  end

  @doc """
  Deletes the header given by `name`.

  All occurrences of the header are deleted, in case the header is repeated multiple times.

  ## Examples

      iex> HTTPSpec.Header.get_header(request, "cache-control")
      ["max-age=600", "no-transform"]
      iex> request = Request.delete_header(req, "cache-control")
      iex> HTTPSpec.Header.get_header(request, "cache-control")
      []

  """
  @spec delete_header(msg(), binary()) :: msg()
  def delete_header(msg, name)
      when (is_struct(msg, Request) or is_struct(msg, Response)) and
             is_binary(name) do
    name = ensure_header_downcase(name)
    %{msg | headers: List.keydelete(msg.headers, name, 0)}
  end

  @doc false
  def ensure_header_downcase(name) do
    String.downcase(name, :ascii)
  end
end
