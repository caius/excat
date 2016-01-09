defmodule Excat do
  # No arguments passed means read from stdin
  def main([]) do
    copy_from(:stdio)
  end

  # Arguments get treated as paths to files, and we ignore stdin
  def main(args) do
    Enum.each(args, fn path -> 
      {:ok, handler} = File.open(path, [:read])

      case copy_from(handler) do
        :ok ->
          File.close(handler)
        
        {:error, reason} ->
          IO.puts :stderr, "excat: #{path}: No such file or directory"
      end
    end)
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

end
