defmodule HTTPSpec.RequestTest do
  use ExUnit.Case

  describe "build/1" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %HTTPSpec.Request{
                scheme: :https,
                host: "www.example.com",
                port: 443,
                method: "POST",
                path: "/",
                headers: [{"accept", "*/*"}],
                body: "",
                query: "key=value"
              }} =
               HTTPSpec.Request.build(
                 scheme: :https,
                 host: "www.example.com",
                 port: 443,
                 method: "POST",
                 path: "/",
                 headers: [{"accept", "*/*"}],
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
              }} = HTTPSpec.Request.build([])
    end
  end

  describe "build!/1" do
    test "returns a struct when options are valid" do
      assert %HTTPSpec.Request{
               scheme: :https,
               host: "www.example.com",
               port: 443,
               method: "POST",
               path: "/",
               headers: [{"accept", "*/*"}],
               body: "",
               query: "key=value"
             } =
               HTTPSpec.Request.build!(
                 scheme: :https,
                 host: "www.example.com",
                 port: 443,
                 method: "POST",
                 path: "/",
                 headers: [{"accept", "*/*"}],
                 body: "",
                 query: "key=value"
               )
    end

    test "raise an exception when options are invalid" do
      assert_raise HTTPSpec.ArgumentError, fn ->
        HTTPSpec.Request.build!([])
      end
    end
  end
end
