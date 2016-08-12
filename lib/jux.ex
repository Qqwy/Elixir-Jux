defmodule Jux do

  # def tokenize_source(source) do
  #   source
  #   |> String.replace("[", "[ ")
  #   |> String.replace("]", " ]")
  #   |> String.split(~r{\s+})
  #   |> Enum.map(&parse_term/1)
  # end

  # def parse_term(term) do
  #   cond do
  #     term =~ ~r{\A\d+\z} -> 
  #       String.to_integer(term)
  #     term =~ ~r{\A\d+\.\d+\z} -> 
  #       String.to_float(term)
  #     :otherwise -> 
  #       term
  #   end
  # end

  def process(source) do
    stack = 
      source
      |> do_process([])
      #|> :lists.reverse # Top of stack is at head.
  end

  def do_process("", stack), do: stack
  def do_process(source, stack) do
    whitespace_regexp = ~r{^\s+}
    float_regexp = ~r{^[+-]?\d+\.\d+}
    integer_regexp = ~r{^[+-]?\d+}
    identifier_regexp = ~r{^[a-z][\w?!]*}

    cond do
      source =~ whitespace_regexp ->
        [_, rest] = pop_token(source, whitespace_regexp)
        do_process(rest, stack)
      String.starts_with?(source, "[") ->
        [quotation, rest] = process_quotation(source)
        new_stack = parse_quotation(quotation, stack)
        do_process(rest, new_stack)
      String.starts_with?(source, "\"") ->
        [string, rest] = process_string(source)
        new_stack = parse_string(string, stack)
        do_process(rest, new_stack)
      source =~ identifier_regexp ->
        [identifier, rest] = pop_token(source, identifier_regexp)
        new_stack = parse_identifier(identifier, stack)
        do_process(rest, new_stack)
        #[parse_identifier(identifier) | do_process(rest)]
      source =~ float_regexp ->
        [float, rest] = pop_token(source, float_regexp)
        new_stack = parse_float(float, stack)
        do_process(rest, new_stack)
        #[parse_float(float) | do_process(rest)]
      source =~ integer_regexp ->
        [integer, rest] = pop_token(source, integer_regexp)
        new_stack = parse_integer(integer, stack)
        do_process(rest, new_stack)
        #[parse_integer(integer) | do_process(rest)]
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
    quotation = String.slice(source, 1, quotation_length - 2)
    IO.inspect [quotation, rest]
    [Jux.Quotation.new(quotation), rest]
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

  def parse_integer(str, stack) do
    integer = 
      str
      |> String.to_integer
    [integer | stack]
    #|> Jux.ConstantFunction.cf
  end

  def parse_float(str, stack) do
    float = 
      str
      |> String.to_float
    [float | stack]
    #|> Jux.ConstantFunction.cf
  end

  def parse_quotation(quotation, stack) do
    [quotation | stack]
    #quotation
    #|> Jux.ConstantFunction.cf
  end

  def process_string(source) do
    [string_length, rest] = do_process_string(String.next_codepoint(source), 0)
    string = String.slice(source, 1, string_length - 2)
    [string, rest]
  end

  def do_process_string({"\"", rest}, 0) do
    do_process_string(String.next_codepoint(rest), 1)
  end

  def do_process_string({"\"", rest}, length) do
    [length+1, rest]
  end

  def do_process_string({"\\", rest}, length) do
    case String.next_codepoint(rest) do
      {"\"", restrest} ->
        do_process_string(restrest, length+2)
      {_, _} ->
        do_process_string(rest, length+1)
    end
  end

  def do_process_string({_, rest}, length) do
    do_process_string(String.next_codepoint(rest), length+1)
  end

  def parse_string(str, stack) do
    [str | stack]
  end

  def parse_identifier(str, stack) do
    atom = str |> String.to_existing_atom
    res = Jux.Stdlib.__info__(:functions)[atom]
    if res != 1 do
      raise ArgumentError, "unknown identifier `#{str}`"
    end
    apply(Jux.Stdlib, atom, [stack])
  end

end
