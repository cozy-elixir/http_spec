defmodule HTTPSpec.Request.URLTest do
  use ExUnit.Case

  alias HTTPSpec.Request.URL

  describe "parse/1" do
    test "HTTP address" do
      assert %{
               scheme: :http,
               host: "www.example.com",
               port: 80,
               path: "/",
               query: "say=hi",
               fragment: "mom"
             } == URL.parse("http://www.example.com/?say=hi#mom")
    end

    test "HTTPS address" do
      assert %{
               scheme: :https,
               host: "www.example.com",
               port: 443,
               path: nil,
               query: "say=hi",
               fragment: "mom"
             } == URL.parse("https://www.example.com?say=hi#mom")
    end

    test "raises an error for other types of URL" do
      assert_raise RuntimeError, "only http:// or https:// address is supported", fn ->
        URL.parse("ssh://user@example.com")
      end
    end
  end
end
