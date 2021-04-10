defmodule RoverBot do
  @input_file "input.txt"
  @output_file "output.txt"
  @default_file_prefix ""
  @directions ["N", "E", "S", "W"]
  @directions_length 4
  @only_digits ~r/\d/

  def main(file_prefix \\ @default_file_prefix) do
    case File.read("#{file_prefix}#{@input_file}") do
      {:ok, content} ->
        [plateau_info | coordinates_and_moves] =
          content
          |> String.split("\n")

        set_plateau_size(plateau_info)

        if valid_plateau?(plateau_size()) do
          rovers_infos = format_rovers_infos(coordinates_and_moves)

          final_coordinates =
            Enum.map(rovers_infos, fn [initial_coordinates, moves] ->
              initial_coordinates = format_coordinates(initial_coordinates)

              moves = format_moves(moves)

              move(moves, initial_coordinates)
            end)

          File.write("#{file_prefix}#{@output_file}", format_content(final_coordinates))
        else
          File.write("#{file_prefix}#{@output_file}", "Invalid plateau size, X ant Y axies must be >= 1")
        end

      {:error, _} ->
        File.write("#{file_prefix}#{@output_file}", "Input file not found")
    end
  end

  defp validate_coordinates(moves, {x_axis, y_axis, direction} = coordinates) do
    if valid_coordinates?(coordinates) do
      move(moves, coordinates)
    else
      {:error, "Out of plateau: {#{x_axis} #{y_axis} #{direction}}"}
    end
  end

  defp move([], coordinates), do: coordinates

  defp move(["M" | next_moves], {x_pos, y_pos, "N"}) do
    validate_coordinates(next_moves, {x_pos, y_pos + 1, "N"})
  end

  defp move(["M" | next_moves], {x_pos, y_pos, "S"}) do
    validate_coordinates(next_moves, {x_pos, y_pos - 1, "S"})
  end

  defp move(["M"| next_moves], {x_pos, y_pos, "E"}) do
    validate_coordinates(next_moves, {x_pos + 1, y_pos, "E"})
  end

  defp move(["M" | next_moves], {x_pos, y_pos, "W"}) do
    validate_coordinates(next_moves, {x_pos - 1, y_pos, "W"})
  end

  defp move(["L" | next_moves], {x_pos, y_pos, direction}) do
    direction_idx = Enum.find_index(@directions, &(&1 == direction))

    direction = Enum.at(@directions, direction_idx - 1)
    validate_coordinates(next_moves, {x_pos, y_pos, direction})
  end

  defp move(["R" | next_moves], {x_pos, y_pos, direction}) do
    direction_idx = Enum.find_index(@directions, &(&1 == direction))

    case direction_idx + 1 do
      @directions_length ->
        validate_coordinates(next_moves, {x_pos, y_pos, "N"})

      _ ->
        direction = Enum.at(@directions, direction_idx + 1)
        validate_coordinates(next_moves, {x_pos, y_pos, direction})
    end
  end

  defp move([invalid_move | _next_moves], _coordinates) do
    {:error, "Invalid movement: #{invalid_move}"}
  end

  defp format_rovers_infos(data) do
    data
    |> Enum.map(&String.split(&1, " "))
    |> Enum.chunk_every(2)
  end

  defp valid_plateau?({x_dim, y_dim}), do: x_dim >= 1 and y_dim >= 1

  defp valid_coordinates?({x_pos, y_pos, _orientation}) do
    {x_plateau, y_plateau} = plateau_size()
    x_pos >= 0 and x_pos <= x_plateau and y_pos >= 0 and y_pos <= y_plateau
  end

  defp format_coordinates(coordinates) do
    coordinates
    |> Enum.map(
      &if Regex.match?(@only_digits, &1) do
        String.to_integer(&1)
      else
        &1
      end
    )
    |> List.to_tuple()
  end

  defp format_moves(moves) do
    moves
    |> List.first()
    |> String.graphemes()
  end

  defp format_content(content) do
    content
    |> Enum.map(fn line ->
      case line do
        {x_axis, y_axis, direction} ->
          "#{x_axis} #{y_axis} #{direction}\n"

        {:error, msg} ->
          "#{msg}\n"
      end
    end)
    |> List.to_string()
  end

  defp set_plateau_size(plateau_size) do
    {x_dim, y_dim} =
      plateau_size
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer(&1))
      |> List.to_tuple()

    :ets.new(:plateau, [:named_table])
    :ets.insert(:plateau, [{:x_dim, x_dim}, {:y_dim, y_dim}])

    {x_dim, y_dim}
  end

  defp plateau_size() do
    [x_dim: x_dim] = :ets.lookup(:plateau, :x_dim)
    [y_dim: y_dim] = :ets.lookup(:plateau, :y_dim)

    {x_dim, y_dim}
  end
end

# TODO
# delete

# case orientation do
#   "N" ->
#     validate_state(tail, {x_pos, y_pos, "E"})

#   "E" ->
#     validate_state(tail, {x_pos, y_pos, "S"})

#   "S" ->
#     validate_state(tail, {x_pos, y_pos, "W"})

#   "W" ->
#     validate_state(tail, {x_pos, y_pos, "N"})
# end
