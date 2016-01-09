defmodule Excat do
  # No arguments passed means read from stdin
  def main([]) do
    main(["-"])
  end

  # Arguments get treated as paths to files, and we ignore stdin
  def main(args) do
    error = Enum.reduce(args, false, fn path, acc ->
      if path == "-" || File.exists?(path) do
        read_path(path)
        acc
      else
        output_error(path)
        true
      end
    end)

    exit_code = if error, do: 1, else: 0
    exit({:shutdown, exit_code})
  end

  def read_path("-") do
    copy_from(:stdio)
  end

  def read_path(path) do
    {:ok, h} = File.open(path, [:read])

    case copy_from(h) do
      :ok ->
        File.close(h)

      {:error, _} ->
        output_error(path)
    end
  end

  # Given a source, read a line from it and write to stdout
  defp copy_from(source) do
    case IO.binread(source, :line) do
      :eof -> :ok
      {:error, reason} -> {:error, reason}
      data ->
        IO.binwrite(data)
        copy_from(source)
    end
  end

  defp output_error(path) do
    IO.puts :stderr, "cat: #{path}: No such file or directory"
  end

end
