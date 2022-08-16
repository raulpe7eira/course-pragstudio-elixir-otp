defmodule Recurse do
  def loopy([head | tail]) do
    IO.puts "Head: #{head} Tail: #{inspect(tail)}"
    loopy(tail)
  end

  def loopy([]), do: IO.puts "Done!"

  def sum([head | tail], total) do
    IO.puts "Total: #{total} Head: #{head} Tail: #{inspect(tail)}"
    sum(tail, total + head)
  end

  def sum([], total), do: total

  # def triple([head|tail]) do
  #   [head*3 | triple(tail)]
  # end

  # def triple([]), do: []
  def triple(list) do
    triple(list, [])
  end

  defp triple([head|tail], current_list) do
    triple(tail, [head*3 | current_list])
  end

  defp triple([], current_list) do
    current_list |> Enum.reverse()
  end
end

Recurse.loopy([1, 2, 3, 4, 5])

Recurse.sum([1, 2, 3, 4, 5], 0)

Recurse.triple([1, 2, 3, 4, 5])
