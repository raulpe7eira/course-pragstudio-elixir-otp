defmodule Servy.Api.BearController do

  alias Servy.{Conv, Wildthings}

  def index(%Conv{} = conv) do
    json =
      Wildthings.list_bears()
      |> Poison.encode!

    %Conv{ conv | status: 200, resp_content_type: "application/json", resp_body: json }
  end
end
