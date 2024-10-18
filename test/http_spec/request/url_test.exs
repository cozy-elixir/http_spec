defmodule HTTPSpec.Request.URLTest do
  use ExUnit.Case

  alias HTTPSpec.Request.URL
  alias HTTPSpec.Request.URL.ParseError

  describe "parse/1" do
    test "HTTP address" do
      assert URL.parse("http://www.example.com/?say=hi#mom") ==
               {:ok,
                %URL{
                  scheme: :http,
                  host: "www.example.com",
                  port: 80,
                  path: "/",
                  query: "say=hi",
                  fragment: "mom"
                }}
    end

    test "HTTPS address" do
      assert URL.parse("https://www.example.com?say=hi#mom") ==
               {:ok,
                %URL{
                  scheme: :https,
                  host: "www.example.com",
                  port: 443,
                  path: nil,
                  query: "say=hi",
                  fragment: "mom"
                }}
    end

    test "raises an error for other types of URL" do
      assert URL.parse("ssh://user@example.com") ==
               {:error, %ParseError{message: "only http:// or https:// address is supported"}}
    end
  end

  describe "parse!/1" do
    test "HTTP address" do
      assert URL.parse!("http://www.example.com/?say=hi#mom") == %URL{
               scheme: :http,
               host: "www.example.com",
               port: 80,
               path: "/",
               query: "say=hi",
               fragment: "mom"
             }
    end

    test "HTTPS address" do
      assert URL.parse!("https://www.example.com?say=hi#mom") == %URL{
               scheme: :https,
               host: "www.example.com",
               port: 443,
               path: nil,
               query: "say=hi",
               fragment: "mom"
             }
    end

    test "raises an error for other types of URL" do
      assert_raise ParseError, "only http:// or https:// address is supported", fn ->
        URL.parse!("ssh://user@example.com")
      end
    end
  end
end
