defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests."

  import Servy.FileHandler, only: [handle_file: 2]
  import Servy.Parser, only: [parse: 1]
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, emojify: 1, track: 1]
  import Servy.View, only: [render: 3]

  alias Servy.{Conv, BearController, Tracker, VideoCam}

  @pages_path Path.expand("../../pages", __DIR__)

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> log
    |> route
    # |> emojify
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot =
      Task.async(fn -> Tracker.get_location("bigfoot") end)
      |> Task.await()

    render(conv, "sensors.eex", snapshots: snapshots, location: where_is_bigfoot)
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %Conv{ conv | status: 200, resp_body: "Awake!" }
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %Conv{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    route(BearController.new(conv, conv.params))
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{ method: "POST", path: "/api/bears" } = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/about" } = conv) do
    route(%Conv{ conv | path: "/pages/about.html" })
  end

  def route(%Conv{ method: "GET", path: "/faq" } = conv) do
    route(%Conv{ conv | path: "/pages/faq.md" })
    |> markdown_to_html
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file)
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ path: path } = conv) do
    %Conv{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{ conv | resp_body: Earmark.as_html!(conv.resp_body) }
  end

  def markdown_to_html(%Conv{} = conv), do: conv

  def put_content_length(%Conv{} = conv) do
    resp_headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    %Conv{ conv | resp_headers: resp_headers }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn {key, value} ->
      "#{key}: #{value}\r"
    end) |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end
end
