defmodule Excat do
  # No arguments means we read stdin
  def main([]) do
    {:ok, ["-"]} |> process_arguments
  end

  # Process arguments in turn
  def main(args) do
    {:ok, args} |> process_arguments
  end

  # Process the next argument
  def process_arguments({state, [path | remaining]}) do
    case copy_file(path, File.exists?(path)) do
      :ok ->
        {state, remaining} |> process_arguments
      :error ->
        {:error, remaining} |> process_arguments
    end
  end

  # Handle no arguments left by exiting
  # Uses state to work out exit code
  def process_arguments({state, []}) do
    exit_code = if state == :ok, do: 0, else: 1
    exit({:shutdown, exit_code})
  end

  # "-" means copy stdin to stdout
  defp copy_file("-", _) do
    IO.binstream(:stdio, :line) |> output
    :ok
  end

  # Copy a file that exists to stdout
  defp copy_file(path, true) do
    File.stream!(path) |> output
    :ok
  end

  # Handle a file not existing, output error to stderr
  defp copy_file(path, false) do
    IO.puts :stderr, "cat: #{path}: No such file or directory"
    :error
  end

  # Output every line from stream to stdout
  defp output(stream) do
    stream |> Enum.each(&IO.write(:stdio, &1))
  end
end
