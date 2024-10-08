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

  describe "operate on headers" do
    setup do
      request = build_request()
      %{request: request}
    end

    test "get_header/2", %{request: request} do
      assert ["application/json"] = Request.get_header(request, "accept")
      assert [] = Request.get_header(request, "content-type")
    end

    test "put_header/3", %{request: request} do
      request = Request.put_header(request, "content-type", "text/html; charset=utf-8")

      assert request.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "put_new_header/3", %{request: request} do
      request1 = Request.put_new_header(request, "accept", "text/html")
      assert request1.headers == [{"accept", "application/json"}]

      request2 = Request.put_new_header(request, "content-type", "text/html; charset=utf-8")

      assert request2.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "put_new_lazy_header/3 with fun/0", %{request: request} do
      request1 = Request.put_new_lazy_header(request, "accept", fn -> "text/html" end)
      assert request1.headers == [{"accept", "application/json"}]

      request2 =
        Request.put_new_lazy_header(request, "content-type", fn -> "text/html; charset=utf-8" end)

      assert request2.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "put_new_lazy_header/3 with fun/1", %{request: request} do
      request1 = Request.put_new_lazy_header(request, "accept", fn _request -> "text/html" end)
      assert request1.headers == [{"accept", "application/json"}]

      request2 =
        Request.put_new_lazy_header(request, "x-scheme", fn request ->
          to_string(request.scheme)
        end)

      assert request2.headers == [
               {"accept", "application/json"},
               {"x-scheme", "https"}
             ]
    end

    test "delete_header/2", %{request: request} do
      request = Request.delete_header(request, "accept")
      assert request.headers == []
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
