defmodule Servy.Api.BearController do

  alias Servy.{Conv, Wildthings}

  def index(%Conv{} = conv) do
    json =
      Wildthings.list_bears()
      |> Poison.encode!

    conv = put_resp_content_type(conv, "application/json")

    %Conv{ conv | status: 200, resp_body: json }
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}!" }
  end

  def put_resp_content_type(%Conv{} = conv, type) do
    resp_headers = Map.put(conv.resp_headers, "Content-Type", type)
    %Conv{ conv | resp_headers: resp_headers }
  end
end
