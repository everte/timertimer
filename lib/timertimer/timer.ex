defmodule Timertimer.Timer do
  def format_ms(nil), do: "00:00:00"

  def format_ms(ms) when is_integer(ms) and ms == 3_355_550 do
    "DNF"
  end

  def format_ms(ms) when is_integer(ms) and ms >= 0 do
    minutes = div(ms, 60_000)
    seconds = div(rem(ms, 60_000), 1000)

    hundredths = div(rem(ms, 1000), 10)

    "#{minutes}:#{pad(seconds)}.#{pad(hundredths)}"
  end

  def parse_time_string(nil), do: 0
  def parse_time_string(""), do: 0

  def parse_time_string(str) when is_binary(str) do
    case split_time_parts(str) do
      [min, sec, hund] -> parse_parts(min, sec, hund)
      _ -> {:error, :invalid_format}
    end
  end

  defp split_time_parts(str) do
    cond do
      String.contains?(str, ":") and String.contains?(str, ".") ->
        [min_sec, hund] = String.split(str, ".", parts: 2)
        [min, sec] = String.split(min_sec, ":", parts: 2)
        [min, sec, hund]

      String.contains?(str, ":") ->
        String.split(str, ":", parts: 3)

      true ->
        []
    end
  end

  defp parse_parts(min, sec, hund) do
    with {m, ""} <- Integer.parse(min),
         {s, ""} <- Integer.parse(sec),
         {h, ""} <- Integer.parse(hund),
         true <- s in 0..59,
         true <- h in 0..99 do
      m * 60_000 + s * 1_000 + h * 10
    else
      _ -> {:error, :invalid_format}
    end
  end

  def ms_to_time(ms) when is_integer(ms) and ms >= 0 do
    milliseconds_since_midnight = rem(ms, 86_400_000)
    hours = div(milliseconds_since_midnight, 3_600_000)
    minutes = div(rem(milliseconds_since_midnight, 3_600_000), 60_000)
    seconds = div(rem(milliseconds_since_midnight, 60_000), 1_000)
    microseconds = rem(ms, 1_000) * 1_000

    Time.new!(hours, minutes, seconds, microseconds)
  end

  def valid_format?(time_string) when is_binary(time_string) do
    case parse_time_string(time_string) do
      {:error, _} -> false
      _ -> true
    end
  end

  defp pad(number, padding \\ 2, char \\ "0") do
    number
    |> Integer.to_string()
    |> String.pad_leading(padding, char)
  end
end
