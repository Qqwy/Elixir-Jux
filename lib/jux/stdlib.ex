defmodule Jux.Stdlib do
  def pop([h | t]) do
    t
  end

  def dup([h | t]) do
    [h, h | t]
  end

  def swap([h1, h2 | t]) do
    [h2, h1 | t]
  end

  def dip([h, quot = %Jux.Quotation{} | t]) do
    [h, Jux.Quotation.call(quot, t)]
  end

  # dup dip pop
  def i([h | t]) do
    Jux.Quotation.call(h, t)
  end

  def inc([h | t]) when is_integer(h) do
    [h+1 | t]
  end

  def dec([h | t]) when is_integer(h) do
    [h-1 | t]
  end

  def add([h1, h2 | t]) do
    [h1+h2 | t]
  end

  def sub([h1, h2 | t]) do
    [h1-h2 | t]
  end

  def eq?([h1, h2 | t]) do
    [h1 == h2 | t]
  end

  name = true
  def unquote(name)(stack) do
    [true | stack]
  end

  name = false
  def unquote(name)(stack) do
    [false | stack]
  end


  def not([true | t]), do: [false | t]
  def not([_     | t]), do: [true | t]

  name = :and
  def unquote(name)([false,     _ | t]), do: false
  def unquote(name)([_    , false | t]), do: false
  def unquote(name)([_    , _     | t]), do: true

  name = :or
  def unquote(name)([false, false | t]), do: false
  def unquote(name)([_    , _     | t]), do: true

  name = :nil
  def unquote(name)(stack), do: [[] | stack]

  def cons([h1, h2 | t]), do: [[h1 | h2] | t]

end