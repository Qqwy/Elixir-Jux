defmodule Parser do
  use Combine

  def parse(str) do
    Combine.parse(str, parser())
  end

  def parser do
    whitespace()
    |> many1(sequence([term(), whitespace()]))
  end

  def whitespace do
    ignore(option(spaces()))
  end

  def term do
    number()
  end

  def number do
    either(float(), integer())
  end
end