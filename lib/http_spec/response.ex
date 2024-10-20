defmodule HTTPSpec.Response do
  @moduledoc """
  A struct for describing HTTP responses.
  """

  alias HTTPSpec.Header
  alias HTTPSpec.Trailer

  @enforce_keys [
    :status,
    :body,
    :headers,
    :trailers
  ]
  defstruct @enforce_keys

  @type status :: non_neg_integer()
  @type body :: iodata() | nil

  @type t :: %__MODULE__{
          status: status(),
          headers: Header.headers(),
          body: body(),
          trailers: Trailer.trailers()
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
  @spec new(keyword() | map()) :: {:ok, t()} | {:error, HTTPSpec.ArgumentError.t()}
  def new(options) when is_list(options) or is_map(options) do
    case NimbleOptions.validate(options, @definition) do
      {:ok, validated_options} ->
        struct =
          validated_options
          |> update_in([:headers], fn headers ->
            for({name, value} <- headers, do: {Header.ensure_header_downcase(name), value})
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
  @spec new!(keyword() | map()) :: t()
  def new!(options) when is_list(options) or is_map(options) do
    case new(options) do
      {:ok, struct} ->
        struct

      {:error, exception} when is_exception(exception) ->
        raise exception
    end
  end
end
