defmodule Excat do
  def main([]) do
    copy_stdin
  end

  def main(args) do
    Enum.each(args, &Excat.copy_file/1)
  end

  def copy_file(filename) do
    case File.read(filename) do
      {:ok, content} ->
        IO.write content

      {:error, reason} ->
        error(filename, reason)

    end
  end

  defp copy_stdin do
    case IO.read(:stdio, :line) do
      :eof -> :ok
      {:error, reason} ->
        error("-", reason)
      data ->
        IO.write(data)
        copy_stdin
    end
  end

  defp error(filename, _) do
    IO.puts :stderr, "excat: #{filename}: No such file or directory"
  end

end
