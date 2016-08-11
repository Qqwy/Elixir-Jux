defmodule Jux do

  def tokenize_source(source) do
    source
    |> String.replace("[", "[ ")
    |> String.replace("]", " ]")
    |> String.split(~r{\s+})
    |> Enum.map(&parse_term/1)
  end

  def parse_term(term) do
    cond do
      term =~ ~r{\A\d+\z} -> 
        String.to_integer(term)
      term =~ ~r{\A\d+\.\d+\z} -> 
        String.to_float(term)
      :otherwise -> 
        term
    end
  end

  def process(source) do
    stack = 
      source
      |> do_process
      |> :lists.reverse # Top of stack is at head.
  end

  def do_process(""), do: []
  def do_process(source) do
    whitespace_regexp = ~r{^\s+}
    float_regexp = ~r{^[+-]?\d+\.\d+}
    integer_regexp = ~r{^[+-]?\d+}
    identifier_regexp = ~r{^[a-z_]\w*}

    cond do
      source =~ whitespace_regexp ->
        [_, rest] = pop_token(source, whitespace_regexp)
        do_process(rest)
      String.starts_with?(source, "[") ->
        [quotation, rest] = process_quotation(source)
        [parse_quotation(quotation) | do_process(rest)]
      source =~ identifier_regexp ->
        [identifier, rest] = pop_token(source, identifier_regexp)
        [parse_identifier(identifier) | do_process(rest)]
      source =~ float_regexp ->
        [float, rest] = pop_token(source, float_regexp)
        [parse_float(float) | do_process(rest)]
      source =~ integer_regexp ->
        [integer, rest] = pop_token(source, integer_regexp)
        [parse_integer(integer) | do_process(rest)]
      :otherwise ->
        raise "Could not parse rest of source: #{inspect source}"
    end
  end

  defp pop_token(source, regex) do 
    [prefix | _] = Regex.run(regex, source)
    [prefix, String.replace_prefix(source, prefix, "")]
  end

  def process_quotation(source) do
    [quotation_length, rest] = do_process_quotation(String.next_codepoint(source), 0, 0)
    quotation = String.slice(source, 1, quotation_length-2)
    IO.inspect [quotation, rest]
    [do_process(quotation), rest]
  end

  def do_process_quotation(nil, _, _) do
    raise "unmatched `[` in input."
  end

  def do_process_quotation({"[", rest}, bracket_count, length_acc) do
    do_process_quotation(String.next_codepoint(rest), bracket_count+1, length_acc+1)
  end

  def do_process_quotation({"]", rest}, 1, length_acc) do
    [length_acc+1, rest]
  end

  def do_process_quotation({"]", rest}, bracket_count, length_acc) do
    do_process_quotation(String.next_codepoint(rest), bracket_count-1, length_acc+1)
  end

  def do_process_quotation({_, rest}, bracket_count, length_acc) do
    do_process_quotation(String.next_codepoint(rest), bracket_count, length_acc+1)
  end

  def parse_integer(str) do
    str
    |> String.to_integer
    #|> Jux.ConstantFunction.cf
  end

  def parse_float(str) do
    str
    |> String.to_float
    #|> Jux.ConstantFunction.cf
  end

  def parse_quotation(quotation) do
    quotation
    |> Jux.ConstantFunction.cf
  end

  def parse_identifier(str) do
    atom = str |> String.to_existing_atom
    res = Jux.Stdlib.__info__(:functions)[atom]
    if res != 1 do
      raise ArgumentError, "unknown identifier `#{str}`"
    end
    #apply Jux.Stdlib, atom, []
    atom
  end

end
