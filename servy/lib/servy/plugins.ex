defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def rewrite_path(%Conv{ path: "/wildlife" } = conv) do
    %Conv{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{ path: "/bears?id=" <> id } = conv) do
    %Conv{ conv | path: "/bears/#{id}" }
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end

    conv
  end

  def emojify(%Conv{ status: 200 } = conv) do
    if Mix.env != :test do
      emojies = String.duplicate("🎉", 5)
      body = emojies <> "\n" <> conv.resp_body <> "\n" <> emojies

      %Conv{ conv | resp_body: body }
    else
      conv
    end
  end

  def emojify(%Conv{} = conv), do: conv

  @doc "Logs 404 requests."
  def track(%Conv{ status: 404, path: path } = conv) do
    if Mix.env != :test do
      Logger.info "Warning: #{path} is on the loose!"
      IO.puts "Warning: #{path} is on the loose!"
    end

    conv
  end

  def track(%Conv{} = conv), do: conv
end
