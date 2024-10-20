defmodule HTTPSpec.Header do
  @moduledoc """
  Helpers for handling headers.
  """

  import HTTPSpec.Guards

  @type headers :: [HTTPSpec.field()]

  @doc """
  Returns the values of the header specified by `name`.

  ## Examples

      iex> HTTPSpec.Header.get_header(request, "accept")
      ["application/json"]
      iex> HTTPSpec.Header.get_header(requset, "x-unknown")
      []

  """
  @spec get_header(HTTPSpec.message(), binary()) :: [binary()]
  def get_header(message, name) when is_message(message) and is_binary(name) do
    name = ensure_downcased_name(name)

    for {^name, value} <- message.headers do
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
  @spec put_header(HTTPSpec.message(), binary(), binary()) :: HTTPSpec.message()
  def put_header(message, name, value)
      when is_message(message) and
             is_binary(name) and
             is_binary(value) do
    name = ensure_downcased_name(name)
    %{message | headers: List.keystore(message.headers, name, 0, {name, value})}
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
  @spec put_new_header(HTTPSpec.message(), binary(), binary()) :: HTTPSpec.message()
  def put_new_header(message, name, value)
      when is_message(message) and
             is_binary(name) and
             is_binary(value) do
    case get_header(message, name) do
      [] -> put_header(message, name, value)
      _ -> message
    end
  end

  @doc """
  Lazy version of `put_new_header/3`.
  """
  @spec put_new_lazy_header(
          HTTPSpec.message(),
          binary(),
          (-> binary()) | (HTTPSpec.message() -> binary())
        ) ::
          HTTPSpec.message()
  def put_new_lazy_header(message, name, fun)
      when is_message(message) and
             is_binary(name) and
             is_function(fun, 0) do
    case get_header(message, name) do
      [] ->
        value = apply(fun, [])
        put_header(message, name, value)

      _ ->
        message
    end
  end

  def put_new_lazy_header(message, name, fun)
      when is_message(message) and
             is_binary(name) and
             is_function(fun, 1) do
    case get_header(message, name) do
      [] ->
        value = apply(fun, [message])
        put_header(message, name, value)

      _ ->
        message
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
  @spec delete_header(HTTPSpec.message(), binary()) :: HTTPSpec.message()
  def delete_header(message, name) when is_message(message) and is_binary(name) do
    name = ensure_downcased_name(name)
    %{message | headers: List.keydelete(message.headers, name, 0)}
  end

  @doc false
  def ensure_downcased_name(name) do
    String.downcase(name, :ascii)
  end
end
