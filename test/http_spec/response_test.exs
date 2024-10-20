defmodule HTTPSpec.ResponseTest do
  use ExUnit.Case

  alias HTTPSpec.Response

  describe "new/1" do
    test "returns {:ok, struct} when options are valid" do
      assert {:ok,
              %Response{
                status: 200,
                body: nil,
                headers: [{"header-a", "value-a"}],
                trailers: [{"header-b", "value-b"}]
              }} =
               Response.new(
                 status: 200,
                 body: nil,
                 headers: [{"Header-a", "value-a"}],
                 trailers: [{"header-b", "value-b"}]
               )

      assert {:ok,
              %Response{
                status: 200,
                body: nil,
                headers: [{"header-a", "value-a"}],
                trailers: [{"header-b", "value-b"}]
              }} =
               Response.new(%{
                 status: 200,
                 body: nil,
                 headers: [{"Header-a", "value-a"}],
                 trailers: [{"header-b", "value-b"}]
               })
    end

    test "returns {:error, exception} when options are invalid" do
      assert {:error,
              %HTTPSpec.ArgumentError{
                message: "required :status option not found, received options: []",
                key: :status,
                value: nil,
                keys_path: []
              }} = Response.new([])
    end
  end

  describe "new!/1" do
    test "returns a struct when options are valid" do
      assert %Response{
               status: 200,
               body: nil,
               headers: [{"header-a", "value-a"}],
               trailers: [{"header-b", "value-b"}]
             } =
               Response.new!(
                 status: 200,
                 body: nil,
                 headers: [{"Header-a", "value-a"}],
                 trailers: [{"header-b", "value-b"}]
               )
    end

    test "raise an exception when options are invalid" do
      assert_raise HTTPSpec.ArgumentError, fn ->
        Response.new!([])
      end
    end
  end
end
