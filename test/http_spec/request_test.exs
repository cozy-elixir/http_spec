defmodule HTTPSpec.RequestTest do
  use ExUnit.Case

  alias HTTPSpec.Request

  describe "build/1" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %Request{
                scheme: :https,
                host: "www.example.com",
                port: 443,
                method: "POST",
                path: "/",
                headers: [{"accept", "*/*"}],
                body: "",
                query: "key=value"
              }} =
               Request.build(
                 scheme: :https,
                 host: "www.example.com",
                 port: 443,
                 method: "POST",
                 path: "/",
                 headers: [{"Accept", "*/*"}],
                 body: "",
                 query: "key=value"
               )
    end

    test "returns {:error, exception} when options are invalid" do
      assert {:error,
              %HTTPSpec.ArgumentError{
                message: "required :scheme option not found, received options: []",
                key: :scheme,
                value: nil,
                keys_path: []
              }} = Request.build([])
    end
  end

  describe "build!/1" do
    test "returns a struct when options are valid" do
      assert %Request{
               scheme: :https,
               host: "www.example.com",
               port: 443,
               method: "POST",
               path: "/",
               headers: [{"accept", "*/*"}],
               body: "",
               query: "key=value"
             } =
               Request.build!(
                 scheme: :https,
                 host: "www.example.com",
                 port: 443,
                 method: "POST",
                 path: "/",
                 headers: [{"Accept", "*/*"}],
                 body: "",
                 query: "key=value"
               )
    end

    test "raise an exception when options are invalid" do
      assert_raise HTTPSpec.ArgumentError, fn ->
        Request.build!([])
      end
    end
  end

  describe "operate on headers" do
    setup do
      request =
        Request.build!(
          scheme: :https,
          host: "www.example.com",
          port: 443,
          method: "POST",
          path: "/",
          headers: [{"accept", "application/json"}],
          body: "",
          query: "key=value"
        )

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

      assert request1.headers == [
               {"accept", "application/json"}
             ]

      request2 = Request.put_new_header(request, "content-type", "text/html; charset=utf-8")

      assert request2.headers == [
               {"accept", "application/json"},
               {"content-type", "text/html; charset=utf-8"}
             ]
    end

    test "delete_header/2", %{request: request} do
      request = Request.delete_header(request, "accept")
      assert request.headers == []
    end
  end
end
