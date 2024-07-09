defmodule HTTPSpec.ResponseTest do
  use ExUnit.Case

  alias HTTPSpec.Response

  describe "build/1" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %Response{
                status: 200,
                body: nil,
                headers: [{"header-a", "value-a"}],
                trailers: [{"header-b", "value-b"}]
              }} =
               Response.build(
                 status: 200,
                 body: nil,
                 headers: [{"header-a", "value-a"}],
                 trailers: [{"header-b", "value-b"}]
               )
    end

    test "returns {:error, exception} when options are invalid" do
      assert {:error,
              %HTTPSpec.ArgumentError{
                message: "required :status option not found, received options: []",
                key: :status,
                value: nil,
                keys_path: []
              }} = Response.build([])
    end
  end

  describe "build!/1" do
    test "returns a struct when options are valid" do
      assert %Response{
               status: 200,
               body: nil,
               headers: [{"header-a", "value-a"}],
               trailers: [{"header-b", "value-b"}]
             } =
               Response.build!(
                 status: 200,
                 body: nil,
                 headers: [{"header-a", "value-a"}],
                 trailers: [{"header-b", "value-b"}]
               )
    end

    test "raise an exception when options are invalid" do
      assert_raise HTTPSpec.ArgumentError, fn ->
        Response.build!([])
      end
    end
  end

  describe "operate on headers" do
    setup do
      response =
        Response.build!(
          status: 200,
          headers: [{"content-type", "application/json"}],
          body: "hello"
        )

      %{response: response}
    end

    test "get_header/2", %{response: response} do
      assert ["application/json"] = Response.get_header(response, "content-type")
      assert [] = Response.get_header(response, "x-unknown")
    end
  end
end
