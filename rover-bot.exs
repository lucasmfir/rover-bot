defmodule RoverBot do
  @input_file "input.txt"
  @plateau_dim {5, 5}
  @d ["N", "E", "S", "W"]

  def main() do
    case File.read(@input_file) do
      {:ok, content} ->
        [plateau_dim | coordinates_and_moves] =
          content
          |> String.split("\n")

        plateau_dim =
          plateau_dim
          |> String.trim()
          |> String.split(" ")
          |> Enum.map(&String.to_integer(&1))
          |> List.to_tuple()

        rovers_infos =
          coordinates_and_moves
          |> Enum.map(&String.split(&1, " "))
          |> Enum.chunk_every(2)

        if valid_plateau?(plateau_dim) do
          resp =
            Enum.map(rovers_infos, fn [initial_coordinates, moves] ->
              initial_coordinates =
                initial_coordinates
                |> Enum.map(
                  &if Regex.match?(~r/\d/, &1) do
                    String.to_integer(&1)
                  else
                    &1
                  end
                )
                |> List.to_tuple()

              moves =
                moves
                |> List.first()
                |> String.graphemes()
                |> move(initial_coordinates)
            end)

          File.write("./output.txt", format_content(resp))
        else
          IO.puts("Invalid plateau size, X ant Y axies must be >= 1")
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp teste(movements, coordinates) do
    if valid_coordinates?(coordinates) and
         movements
         |> List.first()
         |> valid_move?() do
      move(movements, coordinates)
    else
      IO.puts("Invalid")
    end
  end

  defp move([], {x_pos, y_pos, orientation}) do
    {x_pos, y_pos, orientation}
  end

  defp move([head | tail], {x_pos, y_pos, "N"}) when head == "M" do
    teste(tail, {x_pos, y_pos + 1, "N"})
  end

  defp move([head | tail], {x_pos, y_pos, "S"}) when head == "M" do
    teste(tail, {x_pos, y_pos - 1, "S"})
  end

  defp move([head | tail], {x_pos, y_pos, "E"}) when head == "M" do
    teste(tail, {x_pos + 1, y_pos, "E"})
  end

  defp move([head | tail], {x_pos, y_pos, "W"}) when head == "M" do
    teste(tail, {x_pos - 1, y_pos, "W"})
  end

  defp move([head | tail], {x_pos, y_pos, direction}) when head == "L" do
    direction_idx = Enum.find_index(@d, &(&1 == direction))

    direction = Enum.at(@d, direction_idx - 1)
    teste(tail, {x_pos, y_pos, direction})
  end

  defp move([head | tail], {x_pos, y_pos, direction}) when head == "R" do
    direction_idx = Enum.find_index(@d, &(&1 == direction))

    case direction_idx + 1 do
      4 ->
        teste(tail, {x_pos, y_pos, "N"})

      _ ->
        direction = Enum.at(@d, direction_idx + 1)
        teste(tail, {x_pos, y_pos, direction})
    end

    # case orientation do
    #   "N" ->
    #     teste(tail, {x_pos, y_pos, "E"})

    #   "E" ->
    #     teste(tail, {x_pos, y_pos, "S"})

    #   "S" ->
    #     teste(tail, {x_pos, y_pos, "W"})

    #   "W" ->
    #     teste(tail, {x_pos, y_pos, "N"})
    # end
  end

  defp valid_plateau?({x_dim, y_dim}), do: x_dim >= 1 and y_dim >= 1

  defp valid_coordinates?({x_pos, y_pos, _orientation}) do
    {x_plateau, y_plateau} = @plateau_dim
    x_pos >= 0 and x_pos <= x_plateau and y_pos >= 0 and y_pos <= y_plateau
  end

  defp valid_move?(nil), do: true

  defp valid_move?(movement) do
    Regex.match?(~r/M|L|R/, movement)
  end

  defp format_content(content) do
    content
    |> Enum.map(fn {x, y, z} -> "#{x} #{y} #{z}\n" end)
    |> List.to_string()
  end
end
