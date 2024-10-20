defmodule HTTPSpec.Request.QueryParams do
  @moduledoc """
  Helpers for handling key-value pairs which are encoded as query.

  > #### Note {: .info}
  > This module doesn't support Key-value pairs that contains duplicate keys,
  > because the underlying data structure is a map.

  > Because query doesn't always contain key-value pairs, so related helpers
  > are grouped as this extra module.
  """

  defstruct [:internal]

  @type t :: %__MODULE__{
          internal: map()
        }

  @type name :: any()
  @type value :: any()
  @type encoding :: :rfc3986 | :www_form

  @encodings [:rfc3986, :www_form]
  @default_encoding :rfc3986

  @spec new(map()) :: t()
  def new(map \\ %{}) when is_map(map) do
    internal = Enum.into(map, %{}, fn {k, v} -> {to_string(k), v} end)
    %__MODULE__{internal: internal}
  end

  @spec encode(t(), encoding()) :: HTTPSpec.Request.query()
  def encode(%__MODULE__{} = struct, encoding \\ @default_encoding) when encoding in @encodings do
    query = URI.encode_query(struct.internal, encoding)
    if query == "", do: nil, else: query
  end

  @spec decode(HTTPSpec.Request.query(), encoding()) :: t()
  def decode(query, encoding \\ @default_encoding)

  def decode(nil, encoding) when encoding in @encodings do
    internal = %{}
    %__MODULE__{internal: internal}
  end

  def decode(query, encoding) when is_binary(query) and encoding in @encodings do
    map = URI.decode_query(query, %{}, encoding)
    new(map)
  end

  @spec get(t(), name(), value()) :: t()
  def get(%__MODULE__{} = struct, name, default \\ nil) do
    name = to_string(name)
    Map.get(struct.internal, name, default)
  end

  @spec put(t(), name(), value()) :: t()
  def put(%__MODULE__{} = struct, name, value) do
    name = to_string(name)
    %{struct | internal: Map.put(struct.internal, name, value)}
  end

  @spec put_new(t(), name(), value()) :: t()
  def put_new(%__MODULE__{} = struct, name, value) do
    name = to_string(name)
    %{struct | internal: Map.put_new(struct.internal, name, value)}
  end

  @spec put_new_lazy(t(), name(), (-> value())) :: t()
  def put_new_lazy(%__MODULE__{} = struct, name, fun) do
    name = to_string(name)
    %{struct | internal: Map.put_new_lazy(struct.internal, name, fun)}
  end

  @spec delete(t(), name()) :: t()
  def delete(%__MODULE__{} = struct, name) do
    name = to_string(name)
    %{struct | internal: Map.delete(struct.internal, name)}
  end
end
