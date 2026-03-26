#!/usr/bin/env elixir

# Usage: ./extract_boxes.exs your_svg_file.svg

defmodule ExtractBoxes do
  def run(svg_file) do
    IO.puts("Extracting box dimensions from #{svg_file}...")

    dimensions =
      svg_file
      |> File.read!()
      |> extract_boxes()
      |> format_output()

    IO.puts(dimensions)
  end

  defp extract_boxes(svg_content) do
    # Regular expression to match rect elements with box_ IDs
    # This regex now also captures transform if it exists
    regex = ~r/<rect[^>]*id="(box_[^"]*)"[^>]*width="([^"]*)"[^>]*height="([^"]*)"[^>]*x="([^"]*)"[^>]*y="([^"]*)"(?:[^>]*transform="([^"]*)")?[^>]*>/

    Regex.scan(regex, svg_content)
    |> Enum.map(fn captures ->
      case captures do
        [_, id, width, height, x, y, ""] ->
          {id, %{width: width, height: height, x: x, y: y}}
        [_, id, width, height, x, y, transform] ->
          {id, %{width: width, height: height, x: x, y: y, transform: transform}}
        [_, id, width, height, x, y] ->
          {id, %{width: width, height: height, x: x, y: y}}
      end
    end)
  end

  defp format_output(boxes) do
    box_entries =
      boxes
      |> Enum.map(fn {id, attrs} ->
        if Map.has_key?(attrs, :transform) do
          "    \"#{id}\" => %{x: \"#{attrs.x}\", y: \"#{attrs.y}\", width: \"#{attrs.width}\", height: \"#{attrs.height}\", transform: \"#{attrs.transform}\"}"
        else
          "    \"#{id}\" => %{x: \"#{attrs.x}\", y: \"#{attrs.y}\", width: \"#{attrs.width}\", height: \"#{attrs.height}\"}"
        end
      end)
      |> Enum.join(",\n")

    """
    defp get_box_dimensions(box_id) do
      dimensions = %{
    #{box_entries}
      }

      box = dimensions[box_id]
      transform = Map.get(box, :transform)
      if transform do
        {box.x, box.y, box.width, box.height, transform}
      else
        {box.x, box.y, box.width, box.height}
      end
    end
    """
  end
end

case System.argv() do
  [svg_file] -> ExtractBoxes.run(svg_file)
  _ -> IO.puts("Usage: ./extract_boxes.exs <svg_file>")
end



# #!/usr/bin/env elixir

# # Usage: ./extract_boxes.exs your_svg_file.svg

# defmodule ExtractBoxes do
#   def run(svg_file) do
#     IO.puts("Extracting box dimensions from #{svg_file}...")

#     dimensions =
#       svg_file
#       |> File.read!()
#       |> extract_boxes()
#       |> format_output()

#     IO.puts(dimensions)
#   end

#   defp extract_boxes(svg_content) do
#     # Regular expression to match rect elements with box_ IDs
#     regex =
#       ~r/<rect[^>]*id="(box_[^"]*)"[^>]*width="([^"]*)"[^>]*height="([^"]*)"[^>]*x="([^"]*)"[^>]*y="([^"]*)"[^>]*>/

#     Regex.scan(regex, svg_content)
#     |> Enum.map(fn [_, id, width, height, x, y] ->
#       {id, %{width: width, height: height, x: x, y: y}}
#     end)
#   end

#   defp format_output(boxes) do
#     box_entries =
#       boxes
#       |> Enum.map(fn {id, attrs} ->
#         "    \"#{id}\" => %{x: \"#{attrs.x}\", y: \"#{attrs.y}\", width: \"#{attrs.width}\", height: \"#{attrs.height}\"}"
#       end)
#       |> Enum.join(",\n")

#     """
#     defp get_box_dimensions(box_id) do
#       dimensions = %{
#     #{box_entries}
#       }

#       box = dimensions[box_id]
#       {box.x, box.y, box.width, box.height}
#     end
#     """
#   end
# end

# case System.argv() do
#   [svg_file] -> ExtractBoxes.run(svg_file)
#   _ -> IO.puts("Usage: ./extract_boxes.exs <svg_file>")
# end
