defmodule Jux.ConstantFunction do
  defstruct [:val, :f]

  def cf(val), do: %__MODULE__{val: val, f: fn -> val end}

  defimpl Inspect do
    def inspect(cf, opts) do
      "cf(#{inspect cf.val})"
    end
end

end
