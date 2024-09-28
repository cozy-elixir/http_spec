defmodule HTTPSpec.Request do
  @moduledoc """
  A struct for describing HTTP request.
  """

  alias HTTPSpec.Request.URL

  @enforce_keys [:method, :scheme, :host, :port, :path, :query, :fragment, :headers, :body]
  defstruct @enforce_keys

  @type method :: atom() | String.t()
  @type scheme :: :http | :https
  @type host :: String.t()
  @type path :: String.t()
  @type query :: String.t() | nil
  @type fragment :: String.t() | nil
  @type headers :: [{header_name :: String.t(), header_value :: String.t()}]
  @type body :: iodata() | nil

  @type url :: String.t()

  @type t :: %__MODULE__{
          method: method(),
          scheme: scheme(),
          host: host(),
          port: :inet.port_number(),
          path: path(),
          query: query(),
          fragment: fragment(),
          headers: headers(),
          body: body()
        }

  @definition_default_mode NimbleOptions.new!(
                             method: [
                               type: {:or, [:atom, :string]},
                               required: true
                             ],
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
                             path: [
                               type: {:or, [:string, nil]},
                               default: nil
                             ],
                             query: [
                               type: {:or, [:string, nil]},
                               default: nil
                             ],
                             fragment: [
                               type: {:or, [:string, nil]},
                               default: nil
                             ],
                             headers: [
                               type: {:list, {:tuple, [:string, :string]}},
                               default: []
                             ],
                             body: [
                               type: {:or, [{:list, :any}, :string, nil]},
                               default: nil
                             ]
                           )

  @definition_url_mode NimbleOptions.new!(
                         url: [
                           type: {:custom, URL, :type, []},
                           required: true
                         ],
                         method: [
                           type: {:or, [:atom, :string]},
                           required: true
                         ],
                         scheme: [
                           type: {:in, [:http, :https, nil]},
                           default: nil
                         ],
                         host: [
                           type: {:or, [:string, nil]},
                           default: nil
                         ],
                         port: [
                           type: {:or, [{:in, 0..65_535}, nil]},
                           default: nil
                         ],
                         path: [
                           type: {:or, [:string, nil]},
                           default: nil
                         ],
                         query: [
                           type: {:or, [:string, nil]},
                           default: nil
                         ],
                         fragment: [
                           type: {:or, [:string, nil]},
                           default: nil
                         ],
                         headers: [
                           type: {:list, {:tuple, [:string, :string]}},
                           default: []
                         ],
                         body: [
                           type: {:or, [{:list, :any}, :string, nil]},
                           default: nil
                         ]
                       )

  @doc """
  Creates a request from given options.

  The options can be provided as a keyword list or a map.

  ## Examples

      HTTPSpec.Request.new(%{
        method: :post,
        scheme: :https,
        host: "www.example.com",
        port: 443,
        path: "/talk",
        headers: [
          {"content-type", "application/x-www-form-urlencoded"},
          {"accept", "text/html"}
        ],
        body: "say=Hi&to=Mom",
        query: "tone=cute"
      })

  And, an `url` option is provided for setting `scheme`, `host`, `port`, `path`
  and `query` in a quick way.

      HTTPSpec.Request.new(%{
        method: :post,
        url: "https://www.example.com/talk?tone=cute",
        headers: [
          {"content-type", "application/x-www-form-urlencoded"},
          {"accept", "text/html"}
        ],
        body: "say=Hi&to=Mom"
      })

  """
  @spec new(keyword() | map()) :: {:ok, t()} | {:error, HTTPSpec.ArgumentError.t()}
  def new(options) when is_list(options) or is_map(options) do
    default_mode? = !has_option?(options, :url)
    definition = if default_mode?, do: @definition_default_mode, else: @definition_url_mode

    case NimbleOptions.validate(options, definition) do
      {:ok, attrs} ->
        attrs = to_map(attrs)

        struct =
          if default_mode?,
            do: build_request_for_default_mode(attrs),
            else: build_request_for_url_mode(attrs)

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

  defp has_option?(options, name) when is_list(options), do: Keyword.has_key?(options, name)
  defp has_option?(options, name) when is_map(options), do: Map.has_key?(options, name)

  defp build_request_for_default_mode(attrs) do
    attrs
    |> update_in([:headers], fn headers ->
      for({name, value} <- headers, do: {ensure_header_downcase(name), value})
    end)
    |> then(&struct(__MODULE__, &1))
  end

  defp build_request_for_url_mode(attrs) do
    url = attrs.url

    %{
      method: attrs.method,
      scheme: attrs.scheme || url.scheme,
      host: attrs.host || url.host,
      port: attrs.port || url.port,
      path: attrs.path || url.path,
      query: attrs.query || url.query,
      fragment: attrs.fragment || url.fragment,
      headers: attrs.headers,
      body: attrs.body
    }
    |> update_in([:headers], fn headers ->
      for({name, value} <- headers, do: {ensure_header_downcase(name), value})
    end)
    |> then(&struct(__MODULE__, &1))
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

  @doc """
  Returns the values of the header specified by `name`.

  ## Examples

      iex> HTTPSpec.Request.get_header(request, "accept")
      ["application/json"]
      iex> HTTPSpec.Request.get_header(requset, "x-unknown")
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

      iex> HTTPSpec.Request.get_header(request, "accept")
      []
      iex> request = Request.put_header(request, "accept", "application/json")
      iex> HTTPSpec.Request.get_header(request, "accept")
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
      ...>   |> HTTPSpec.Request.put_new_header("accept", "application/json")
      ...>   |> HTTPSpec.Request.put_new_header("accept", "text/html")
      iex> HTTPSpec.Request.get_header(request, "accept")
      ["application/json"]

  """
  @spec put_new_header(t(), binary(), binary()) :: t()
  def put_new_header(%__MODULE__{} = request, name, value)
      when is_binary(name) and is_binary(value) do
    case get_header(request, name) do
      [] -> put_header(request, name, value)
      _ -> request
    end
  end

  @doc """
  Lazy version of `put_new_header/3`.
  """
  @spec put_new_lazy_header(t(), binary(), (-> binary()) | (t() -> binary())) :: t()
  def put_new_lazy_header(%__MODULE__{} = request, name, fun)
      when is_binary(name) and is_function(fun, 0) do
    case get_header(request, name) do
      [] ->
        value = apply(fun, [])
        put_header(request, name, value)

      _ ->
        request
    end
  end

  def put_new_lazy_header(%__MODULE__{} = request, name, fun)
      when is_binary(name) and is_function(fun, 1) do
    case get_header(request, name) do
      [] ->
        value = apply(fun, [request])
        put_header(request, name, value)

      _ ->
        request
    end
  end

  @doc """
  Deletes the header given by `name`.

  All occurrences of the header are deleted, in case the header is repeated multiple times.

  ## Examples

      iex> HTTPSpec.Request.get_header(request, "cache-control")
      ["max-age=600", "no-transform"]
      iex> request = Request.delete_header(req, "cache-control")
      iex> HTTPSpec.Request.get_header(request, "cache-control")
      []

  """
  @spec delete_header(t(), binary()) :: t()
  def delete_header(%__MODULE__{} = request, name) when is_binary(name) do
    name = ensure_header_downcase(name)
    %{request | headers: List.keydelete(request.headers, name, 0)}
  end

  @doc """
  Puts body into request.
  """
  @spec put_body(t(), body()) :: t()
  def put_body(%__MODULE__{} = request, body)
      when is_list(body) or is_binary(body) or is_nil(body) do
    %{request | body: body}
  end

  @doc """
  Puts query into request.
  """
  @spec put_query(t(), query()) :: t()
  def put_query(%__MODULE__{} = request, query)
      when is_binary(query) or is_nil(query) do
    %{request | query: query}
  end

  @doc """
  Builds a method.

  ## Examples

      iex> request = HTTPSpec.Request.new!([method: :post, ...])
      iex> HTTPSpec.Request.build_method(request)
      "POST"

      iex> request = HTTPSpec.Request.new!(method: "POST", ...)
      iex> HTTPSpec.Request.build_method(request)
      "POST"

  """
  @spec build_method(t()) :: String.t()
  def build_method(%__MODULE__{} = request) do
    request.method |> to_string() |> String.upcase()
  end

  @doc """
  Builds an URL.

  ## Examples

      iex> request = HTTPSpec.Request.new!(
      ...>   method: :get
      ...>   scheme: :https,
      ...>   host: "www.example.com",
      ...>   port: 443,
      ...>   path: "/image.png",
      ...>   query: "size=lg",
      ...>   fragment: "124,28"
      ...> )
      iex> HTTPSpec.Request.build_url(request)
      "https://www.example.com/image.png?size=lg#124,28"

  """
  @spec build_url(t()) :: String.t()
  def build_url(%__MODULE__{} = request) do
    %URI{
      scheme: to_string(request.scheme),
      host: request.host,
      port: request.port,
      path: request.path,
      query: request.query,
      fragment: request.fragment
    }
    |> URI.to_string()
  end

  defp ensure_header_downcase(name) do
    String.downcase(name, :ascii)
  end

  defp to_map(term) when not is_map(term), do: Map.new(term)
  defp to_map(map), do: map
end
