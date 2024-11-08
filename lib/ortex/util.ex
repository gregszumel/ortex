defmodule Ortex.Util do
  @moduledoc false
  @doc """
    Copies the libraries downloaded during the ORT build into a path that
    Elixir can use
  """
  def copy_ort_libs() do
    build_root = Path.absname(:code.priv_dir(:ortex)) |> Path.dirname()

    rust_env =
      case Path.join([build_root, "native/ortex/release"]) |> File.ls() do
        {:ok, _} -> "release"
        _ -> "debug"
      end

    # where the libonnxruntime files are stored
    rust_path = Path.join([build_root, "native/ortex", rust_env])

    onnx_runtime_paths =
      case :os.type() do
        {:win32, _} -> Path.join([rust_path, "libonnxruntime*.dll*"])
        {:unix, :darwin} -> Path.join([rust_path, "libonnxruntime*.dylib*"])
        {:unix, _} -> Path.join([rust_path, "libonnxruntime*.so*"])
      end
      |> Path.wildcard()

    # where we need to copy the paths
    destination_dir = Path.join([:code.priv_dir(:ortex), "native"])

    onnx_runtime_paths
    |> Enum.map(fn x ->
      File.cp!(x, Path.join([destination_dir, Path.basename(x)]))
    end)
  end
end
