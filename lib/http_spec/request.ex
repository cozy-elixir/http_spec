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
                  required: true
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
        {:ok, struct(__MODULE__, validated_options)}

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
end
