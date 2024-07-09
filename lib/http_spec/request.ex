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
  @type host :: String.t()
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

  @definition NimbleOptions.new!(
                scheme: [
                  type: {:in, [:http, :https]},
                  required: true
                ],
                host: [
                  type: :string,
                  required: true
                ],
                port: [
                  type: {:in, 0..65_535},
                  required: true
                ],
                method: [
                  type: {:or, [:atom, :string]},
                  required: true
                ],
                path: [
                  type: :string,
                  default: "/"
                ],
                headers: [
                  type: {:list, {:tuple, [:string, :string]}},
                  default: []
                ],
                body: [
                  type: {:or, [{:list, :any}, :string, nil]},
                  default: nil
                ],
                query: [
                  type: {:or, [:string, nil]},
                  default: nil
                ]
              )

  @spec build(keyword() | map()) ::
          {:ok, __MODULE__.t()} | {:error, HTTPSpec.ArgumentError.t()}
  def build(options) do
    case NimbleOptions.validate(options, @definition) do
      {:ok, validated_options} ->
        struct =
          validated_options
          |> Keyword.update!(:headers, fn headers ->
            for({name, value} <- headers, do: {ensure_header_downcase(name), value})
          end)
          |> then(&struct(__MODULE__, &1))

        {:ok, struct}

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error,
         %HTTPSpec.ArgumentError{
           message: error.message,
           key: error.key,
           value: error.value,
           keys_path: error.keys_path
         }}
    end
  end

  @spec build!(keyword() | map()) :: __MODULE__.t()
  def build!(options) do
    case build(options) do
      {:ok, struct} ->
        struct

      {:error, exception} when is_exception(exception) ->
        raise exception
    end
  end

  @doc """
  Returns the values of the header specified by `name`.

  ## Examples

      iex> Request.get_header(request, "accept")
      ["application/json"]
      iex> Request.get_header(requset, "x-unknown")
      []

  """
  @spec get_header(t(), binary()) :: [binary()]
  def get_header(%__MODULE__{} = request, name) when is_binary(name) do
    name = ensure_header_downcase(name)

    for {^name, value} <- request.headers do
      value
    end
  end

  @doc """
  Puts a request header `name` to `value`.

  If the header was previously set, its value is overwritten.

  ## Examples

      iex> Request.get_header(request, "accept")
      []
      iex> request = Request.put_header(request, "accept", "application/json")
      iex> Request.get_header(request, "accept")
      ["application/json"]

  """
  @spec put_header(t(), binary(), binary()) :: t()
  def put_header(%__MODULE__{} = request, name, value)
      when is_binary(name) and is_binary(value) do
    name = ensure_header_downcase(name)
    %{request | headers: List.keystore(request.headers, name, 0, {name, value})}
  end

  @doc """
  Puts a request header `name` to `value` unless already present.

  See `put_header/3` for more information.

  ## Examples

      iex> request =
      ...>   request
      ...>   |> Req.Request.put_new_header("accept", "application/json")
      ...>   |> Req.Request.put_new_header("accept", "text/html")
      iex> Req.Request.get_header(request, "accept")
      ["application/json"]

  """
  @spec put_new_header(t(), binary(), binary()) :: t()
  def put_new_header(%__MODULE__{} = request, name, value) do
    case get_header(request, name) do
      [] -> put_header(request, name, value)
      _ -> request
    end
  end

  @doc """
  Deletes the header given by `name`.

  All occurrences of the header are deleted, in case the header is repeated multiple times.

  ## Examples

      iex> Request.get_header(request, "cache-control")
      ["max-age=600", "no-transform"]
      iex> request = Request.delete_header(req, "cache-control")
      iex> Req.Request.get_header(request, "cache-control")
      []

  """
  @spec delete_header(t(), binary()) :: t()
  def delete_header(%__MODULE__{} = request, name) when is_binary(name) do
    name = ensure_header_downcase(name)
    %{request | headers: List.keydelete(request.headers, name, 0)}
  end

  defp ensure_header_downcase(name) do
    String.downcase(name, :ascii)
  end
end
