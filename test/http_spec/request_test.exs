defmodule HTTPSpec.RequestTest do
  use ExUnit.Case

  alias HTTPSpec.Request

  describe "new/1" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %Request{
                scheme: :https,
                host: "www.example.com",
                port: 443,
                method: "POST",
                path: "/",
                query: "key=value",
                fragment: "tail",
                headers: [{"accept", "*/*"}],
                body: ""
              }} =
               Request.new(
                 scheme: :https,
                 host: "www.example.com",
                 port: 443,
                 method: "POST",
                 path: "/",
                 query: "key=value",
                 fragment: "tail",
                 headers: [{"Accept", "*/*"}],
                 body: ""
               )
    end

    test "returns {:error, exception} when options are invalid" do
      assert {:error,
              %HTTPSpec.ArgumentError{
                message: "required :method option not found, received options: []",
                key: :method,
                value: nil,
                keys_path: []
              }} = Request.new([])
    end
  end

  describe "new/1 (url mode)" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %Request{
                scheme: :https,
                host: "www.example.com",
                port: 443,
                method: "POST",
                path: "/",
                query: "key=value",
                fragment: "tail",
                headers: [{"accept", "*/*"}],
                body: ""
              }} =
               Request.new(
                 method: "POST",
                 url: "https://www.example.com/?key=value#tail",
                 headers: [{"Accept", "*/*"}],
                 body: ""
               )
    end

    test "allows overriding the value parsed from url" do
      assert {:ok,
              %Request{
                method: "POST",
                scheme: :http,
                host: "example.com",
                port: 80,
                path: "/hello",
                query: "k=v",
                fragment: "tailor",
                headers: [{"accept", "*/*"}],
                body: ""
              }} =
               Request.new(
                 method: "POST",
                 url: "https://www.example.com/?key=value#tail",
                 headers: [{"Accept", "*/*"}],
                 body: "",
                 # overrides
                 scheme: :http,
                 host: "example.com",
                 port: 80,
                 path: "/hello",
                 query: "k=v",
                 fragment: "tailor"
               )
    end

    test "returns error when url is invalid" do
      assert {:error,
              %HTTPSpec.ArgumentError{
                message:
                  "invalid value for :url option: only http:// or https:// address is supported",
                key: :url,
                value: "ftp://www.example.com/?key=value#tail",
                keys_path: []
              }} =
               Request.new(
                 method: "POST",
                 url: "ftp://www.example.com/?key=value#tail",
                 headers: [{"Accept", "*/*"}],
                 body: ""
               )
    end
  end

  describe "new!/1" do
    test "returns a struct when options are valid" do
      assert %Request{
               scheme: :https,
               host: "www.example.com",
               port: 443,
               method: "POST",
               path: "/",
               query: "key=value",
               fragment: "tail",
               headers: [{"accept", "*/*"}],
               body: ""
             } =
               Request.new!(
                 scheme: :https,
                 host: "www.example.com",
                 port: 443,
                 method: "POST",
                 path: "/",
                 query: "key=value",
                 fragment: "tail",
                 headers: [{"Accept", "*/*"}],
                 body: ""
               )
    end

    test "raise an exception when options are invalid" do
      assert_raise HTTPSpec.ArgumentError, fn ->
        Request.new!([])
      end
    end
  end

  describe "operate on query" do
    setup do
      request = build_request()
      %{request: request}
    end

    test "put_query/2", %{request: request} do
      assert %Request{query: "querystring"} = Request.put_query(request, "querystring")
    end
  end

  describe "operate on body" do
    setup do
      request = build_request()
      %{request: request}
    end

    test "put_body", %{request: request} do
      assert %Request{body: "raw"} = Request.put_body(request, "raw")
    end
  end

  describe "build_method/1" do
    test "works for atom" do
      request = build_request(method: :post)
      assert "POST" == Request.build_method(request)
    end

    test "works for string" do
      request = build_request(method: "POST")
      assert "POST" == Request.build_method(request)
    end
  end

  describe "build_url/1" do
    test "works" do
      # a requset for accessing a given position of an image
      request =
        build_request(
          method: :get,
          scheme: :https,
          host: "www.example.com",
          port: 443,
          path: "/image.png",
          query: "size=lg",
          fragment: "124,28"
        )

      assert "https://www.example.com/image.png?size=lg#124,28" ==
               Request.build_url(request)
    end
  end

  defp build_request(overrides \\ []) do
    default = [
      method: :post,
      scheme: :https,
      host: "www.example.com",
      port: 443,
      path: "/",
      query: "key=value",
      headers: [{"accept", "application/json"}],
      body: ""
    ]

    default
    |> Keyword.merge(overrides)
    |> Request.new!()
  end
end
