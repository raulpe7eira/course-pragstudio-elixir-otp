defmodule Servy.BearController do

  alias Servy.Bear
  alias Servy.Conv
  alias Servy.Wildthings

  @templates_path Path.expand("../../templates", __DIR__)

  def index(%Conv{} = conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    render(conv, "index.eex", bears: bears)
  end

  def route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    route(%Conv{ conv | path: "/pages/form" })
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def delete(%Conv{} = conv, %{"id" => id}) do
    %Conv{ conv | status: 403, resp_body: "Deleting a bear #{id} is forbidden!"}
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %Conv{ conv | status: 201, resp_body: "Create a #{type} bear named #{name}!" }
  end

  defp render(%Conv{} = conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %Conv{ conv | status: 200, resp_body: content }
  end
end
