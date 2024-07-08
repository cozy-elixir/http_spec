defmodule HTTPSpec.ResponseTest do
  use ExUnit.Case

  describe "build/1" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %HTTPSpec.Response{
                status: 200,
                body: nil,
                headers: [{"header-a", "value-a"}],
                trailers: [{"header-b", "value-b"}]
              }} =
               HTTPSpec.Response.build(
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
              }} = HTTPSpec.Response.build([])
    end
  end

  describe "build!/1" do
    test "returns a struct when options are valid" do
      assert %HTTPSpec.Response{
               status: 200,
               body: nil,
               headers: [{"header-a", "value-a"}],
               trailers: [{"header-b", "value-b"}]
             } =
               HTTPSpec.Response.build!(
                 status: 200,
                 body: nil,
                 headers: [{"header-a", "value-a"}],
                 trailers: [{"header-b", "value-b"}]
               )
    end

    test "raise an exception when options are invalid" do
      assert_raise HTTPSpec.ArgumentError, fn ->
        HTTPSpec.Response.build!([])
      end
    end
  end
end
