defmodule HTTPSpec.Response do
  @moduledoc """
  A struct for describing HTTP response.
  """

  defstruct [
    :status,
    :body,
    headers: [],
    trailers: []
  ]

  @type status :: non_neg_integer()
  @type body :: binary() | nil
  @type headers :: [{header_name :: String.t(), header_value :: String.t()}]

  @type t :: %__MODULE__{
          status: status(),
          headers: headers(),
          body: body(),
          trailers: headers()
        }

  @definition NimbleOptions.new!(
                status: [
                  type: {:in, 200..599},
                  required: true
                ],
                headers: [
                  type: {:list, {:tuple, [:string, :string]}},
                  default: []
                ],
                body: [
                  type: {:or, [:string, nil]},
                  default: nil
                ],
                trailers: [
                  type: {:list, {:tuple, [:string, :string]}},
                  default: []
                ]
              )

  @doc """
  Creates a response from given options.

  The options can be provided as a keyword list or a map.

  ## Examples

      HTTPSpec.Response.new(%{
        status: 200,
        headers: [
          {"content-type", "text/html"}
        ],
        body: "<html>...</html>"
      })

  """
  @spec new(keyword() | map()) ::
          {:ok, __MODULE__.t()} | {:error, HTTPSpec.ArgumentError.t()}
  def new(options) when is_list(options) or is_map(options) do
    case NimbleOptions.validate(options, @definition) do
      {:ok, validated_options} ->
        struct =
          validated_options
          |> update_in([:headers], fn headers ->
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

  @doc """
  Bang version of `new/1`.
  """
  @spec new!(keyword() | map()) :: __MODULE__.t()
  def new!(options) when is_list(options) or is_map(options) do
    case new(options) do
      {:ok, struct} ->
        struct

      {:error, exception} when is_exception(exception) ->
        raise exception
    end
  end

  @doc """
  Returns the values of the header specified by `name`.

  ## Examples

      iex> HTTPSpec.Response.get_header(response, "content-type")
      ["application/json"]

      iex> HTTPSpec.Response.get_header(response, "x-unknown")
      []

  """
  @spec get_header(t(), binary()) :: [binary()]
  def get_header(%__MODULE__{} = response, name) when is_binary(name) do
    for {^name, value} <- response.headers do
      value
    end
  end

  @doc """
  Returns the values of the trailer specified by `name`.

  ## Examples

      iex> HTTPSpec.Response.get_trailer(response, "expires")
      ["Wed, 21 Oct 2015 07:28:00 GMT"]

      iex> HTTPSpec.Response.get_trailer(response, "x-unknown")
      []

  """
  @spec get_trailer(t(), binary()) :: [binary()]
  def get_trailer(%__MODULE__{} = response, name) when is_binary(name) do
    for {^name, value} <- response.trailers do
      value
    end
  end

  defp ensure_header_downcase(name) do
    String.downcase(name, :ascii)
  end
end
