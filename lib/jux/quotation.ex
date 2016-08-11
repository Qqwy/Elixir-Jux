defmodule Jux.Quotation do
  defstruct [:source]

  def new(str) do
    %Jux.Quotation{source: str}
  end

  def call(quotation = %Jux.Quotation{}, stack) do
    Jux.do_process(quotation.source, stack)
  end

  # defimpl Inspect do
  #   def inspect(quotation, _opts) do
  #     "[#{quotation.source}]"
  #   end
  # end
end 