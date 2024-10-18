defmodule HTTPSpec.Request.QueryParamsTest do
  use ExUnit.Case

  alias HTTPSpec.Request.QueryParams

  test "new/1" do
    assert QueryParams.new() == %QueryParams{internal: %{}}
    assert QueryParams.new(%{key: "value "}) == %QueryParams{internal: %{"key" => "value "}}
  end

  test "encode/_" do
    assert build_query(%{}) |> QueryParams.encode() == nil
    assert build_query(%{key: "value "}) |> QueryParams.encode() == "key=value%20"
    assert build_query(%{key: "value "}) |> QueryParams.encode(:rfc3986) == "key=value%20"
    assert build_query(%{key: "value "}) |> QueryParams.encode(:www_form) == "key=value+"
  end

  test "decode/_" do
    assert QueryParams.decode(nil) == %QueryParams{internal: %{}}
    assert QueryParams.decode("key=value%20") == %QueryParams{internal: %{"key" => "value "}}

    assert QueryParams.decode("key=value%20", :rfc3986) == %QueryParams{
             internal: %{"key" => "value "}
           }

    assert QueryParams.decode("key=value+", :www_form) == %QueryParams{
             internal: %{"key" => "value "}
           }
  end

  test "put/3" do
    assert build_query() |> QueryParams.put("key", "value") == %QueryParams{
             internal: %{"key" => "value"}
           }
  end

  test "put_new/3" do
    assert build_query(%{"key" => "value"}) |> QueryParams.put_new("key", "value1") ==
             %QueryParams{internal: %{"key" => "value"}}

    assert build_query(%{"key" => "value"}) |> QueryParams.put_new("key1", "value1") ==
             %QueryParams{internal: %{"key" => "value", "key1" => "value1"}}
  end

  test "put_new_lazy/3" do
    assert build_query(%{"key" => "value"})
           |> QueryParams.put_new_lazy("key", fn -> "value1" end) == %QueryParams{
             internal: %{"key" => "value"}
           }

    assert build_query(%{"key" => "value"})
           |> QueryParams.put_new_lazy("key1", fn -> "value1" end) == %QueryParams{
             internal: %{"key" => "value", "key1" => "value1"}
           }
  end

  test "delete/2" do
    struct = build_query(%{"key" => "value"}) |> QueryParams.delete("key")
    refute Map.has_key?(struct.internal, "key")
  end

  defp build_query(map \\ %{}) do
    QueryParams.new(map)
  end
end
