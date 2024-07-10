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

  describe "operate on headers" do
    setup do
      response =
        build_response(
          headers: [{"content-type", "application/json"}, {"trailer", "expires"}],
          trailers: [{"expires", "Wed, 21 Oct 2015 07:28:00 GMT"}]
        )

      %{response: response}
    end

    test "get_header/2", %{response: response} do
      assert ["application/json"] = Response.get_header(response, "content-type")
      assert [] = Response.get_header(response, "x-unknown")
    end

    test "get_trailer/2", %{response: response} do
      assert ["Wed, 21 Oct 2015 07:28:00 GMT"] = Response.get_trailer(response, "expires")
      assert [] = Response.get_trailer(response, "x-unknown")
    end
  end

  defp build_response(overrides) do
    default = [
      status: 200,
      headers: [],
      body: nil
    ]

    default
    |> Keyword.merge(overrides)
    |> Response.new!()
  end
end
