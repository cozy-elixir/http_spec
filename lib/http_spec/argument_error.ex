defmodule HTTPSpec.ArgumentError do
  @moduledoc """
  An error that is returned (or raised) when given options are invalid.
  """

  defexception [:message, :key, :value, keys_path: []]

  @type t() :: %__MODULE__{
          key: atom(),
          keys_path: [atom()],
          value: term()
        }
end
