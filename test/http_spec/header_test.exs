defmodule HTTPSpec.HeaderTest do
  use ExUnit.Case

  alias HTTPSpec.Request
  alias HTTPSpec.Response
  alias HTTPSpec.Header

  describe "operate on requests" do
    setup do
      request = build_request()
      %{request: request}
    end

    test "get_header/2", %{request: request} do
      assert ["application/json"] = Header.get_header(request, "accept")
      assert [] = Header.get_header(request, "content-type")
    end

    test "put_header/3", %{request: request} do
      request = Header.put_header(request, "content-type", "text/html; charset=utf-8")

      assert request.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "put_new_header/3", %{request: request} do
      request1 = Header.put_new_header(request, "accept", "text/html")
      assert request1.headers == [{"accept", "application/json"}]

      request2 = Header.put_new_header(request, "content-type", "text/html; charset=utf-8")

      assert request2.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "put_new_lazy_header/3 with fun/0", %{request: request} do
      request1 = Header.put_new_lazy_header(request, "accept", fn -> "text/html" end)
      assert request1.headers == [{"accept", "application/json"}]

      request2 =
        Header.put_new_lazy_header(request, "content-type", fn -> "text/html; charset=utf-8" end)

      assert request2.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "put_new_lazy_header/3 with fun/1", %{request: request} do
      request1 = Header.put_new_lazy_header(request, "accept", fn _request -> "text/html" end)
      assert request1.headers == [{"accept", "application/json"}]

      request2 =
        Header.put_new_lazy_header(request, "x-scheme", fn request ->
          to_string(request.scheme)
        end)

      assert request2.headers == [
               {"accept", "application/json"},
               {"x-scheme", "https"}
             ]
    end

    test "delete_header/2", %{request: request} do
      request = Header.delete_header(request, "accept")
      assert request.headers == []
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

  describe "operate on responses" do
    setup do
      response = build_response()
      %{response: response}
    end

    test "get_header/2", %{response: response} do
      assert ["application/json"] = Header.get_header(response, "content-type")
      assert [] = Header.get_header(response, "content-encoding")
    end

    test "put_header/3", %{response: response} do
      response = Header.put_header(response, "content-encoding", "gzip")

      assert response.headers == [
               {"content-type", "application/json"},
               {"content-encoding", "gzip"}
             ]
    end

    test "put_new_header/3", %{response: response} do
      response1 = Header.put_new_header(response, "content-type", "text/html")
      assert response1.headers == [{"content-type", "application/json"}]

      response2 = Header.put_new_header(response, "content-encoding", "gzip")

      assert response2.headers == [
               {"content-type", "application/json"},
               {"content-encoding", "gzip"}
             ]
    end

    test "put_new_lazy_header/3 with fun/0", %{response: response} do
      response1 = Header.put_new_lazy_header(response, "content-type", fn -> "text/html" end)
      assert response1.headers == [{"content-type", "application/json"}]

      response2 =
        Header.put_new_lazy_header(response, "content-encoding", fn -> "gzip" end)

      assert response2.headers == [
               {"content-type", "application/json"},
               {"content-encoding", "gzip"}
             ]
    end

    test "put_new_lazy_header/3 with fun/1", %{response: response} do
      response1 =
        Header.put_new_lazy_header(response, "content-type", fn _response -> "text/html" end)

      assert response1.headers == [{"content-type", "application/json"}]

      response2 =
        Header.put_new_lazy_header(response, "x-status", fn response ->
          to_string(response.status)
        end)

      assert response2.headers == [
               {"content-type", "application/json"},
               {"x-status", "200"}
             ]
    end

    test "delete_header/2", %{response: response} do
      response = Header.delete_header(response, "content-type")
      assert response.headers == []
    end

    defp build_response(overrides \\ []) do
      default = [
        status: 200,
        headers: [{"content-type", "application/json"}],
        body: "",
        trailers: []
      ]

      default
      |> Keyword.merge(overrides)
      |> Response.new!()
    end
  end
end
