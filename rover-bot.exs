defmodule RoverBot do
  @default_input_file "input.txt"
  @directions ["N", "E", "S", "W"]
  @directions_length 4
  @only_digits ~r/\d/

  def main(input_file \\ @default_input_file) do
    case File.read(input_file) do
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

          File.write("./output.txt", format_content(final_coordinates))
        else
          File.write("./output.txt", "Invalid plateau size, X ant Y axies must be >= 1")
        end

      {:error, reason} ->
        {:error, reason}
    end

    IO.puts("end script")
  end

  defp validate_coordinates(movements, {x_axis, y_axis, direction} = coordinates) do
    if valid_coordinates?(coordinates) do
      move(movements, coordinates)
    else
      {:error, "Out of plateau: {#{x_axis} #{y_axis} #{direction}}"}
    end
  end

  defp move([], {x_pos, y_pos, orientation}) do
    {x_pos, y_pos, orientation}
  end

  defp move(["M" | tail], {x_pos, y_pos, "N"}) do
    validate_coordinates(tail, {x_pos, y_pos + 1, "N"})
  end

  defp move([head | tail], {x_pos, y_pos, "S"}) when head == "M" do
    validate_coordinates(tail, {x_pos, y_pos - 1, "S"})
  end

  defp move([head | tail], {x_pos, y_pos, "E"}) when head == "M" do
    validate_coordinates(tail, {x_pos + 1, y_pos, "E"})
  end

  defp move([head | tail], {x_pos, y_pos, "W"}) when head == "M" do
    validate_coordinates(tail, {x_pos - 1, y_pos, "W"})
  end

  defp move([head | tail], {x_pos, y_pos, direction}) when head == "L" do
    direction_idx = Enum.find_index(@directions, &(&1 == direction))

    direction = Enum.at(@directions, direction_idx - 1)
    validate_coordinates(tail, {x_pos, y_pos, direction})
  end

  defp move([head | tail], {x_pos, y_pos, direction}) when head == "R" do
    direction_idx = Enum.find_index(@directions, &(&1 == direction))

    case direction_idx + 1 do
      @directions_length ->
        validate_coordinates(tail, {x_pos, y_pos, "N"})

      _ ->
        direction = Enum.at(@directions, direction_idx + 1)
        validate_coordinates(tail, {x_pos, y_pos, direction})
    end
  end

  defp move([head | tail], {x_pos, y_pos, orientation}) do
    {:error, "Invalid movement: #{head}"}
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
