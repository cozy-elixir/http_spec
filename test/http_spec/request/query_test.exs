defmodule HTTPSpec.Request.QueryTest do
  use ExUnit.Case

  alias HTTPSpec.Request.Query

  test "new/1" do
    assert %Query{internal: %{}} = Query.new()
    assert %Query{internal: %{"key" => "value"}} = Query.new(%{key: "value"})
  end

  test "encode/2" do
    assert nil == build_query(%{}) |> Query.encode()
    assert "key=value" == build_query(%{key: "value"}) |> Query.encode()
  end

  test "decode/2" do
    assert %Query{internal: %{}} == nil |> Query.decode()
    assert %Query{internal: %{"key" => "value"}} == "key=value" |> Query.decode()
  end

  test "put/3" do
    assert %Query{internal: %{"key" => "value"}} = build_query() |> Query.put("key", "value")
  end

  test "put_new/3" do
    assert %Query{internal: %{"key" => "value"}} =
             build_query(%{"key" => "value"}) |> Query.put_new("key", "value1")

    assert %Query{internal: %{"key" => "value", "key1" => "value1"}} =
             build_query(%{"key" => "value"}) |> Query.put_new("key1", "value1")
  end

  test "put_new_lazy/3" do
    assert %Query{internal: %{"key" => "value"}} =
             build_query(%{"key" => "value"}) |> Query.put_new_lazy("key", fn -> "value1" end)

    assert %Query{internal: %{"key" => "value", "key1" => "value1"}} =
             build_query(%{"key" => "value"}) |> Query.put_new_lazy("key1", fn -> "value1" end)
  end

  test "delete/2" do
    struct = build_query(%{"key" => "value"}) |> Query.delete("key")
    assert nil == Map.get(struct, "key")
  end

  defp build_query(map \\ %{}) do
    Query.new(map)
  end
end
