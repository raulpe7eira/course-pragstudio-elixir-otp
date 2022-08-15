defmodule Servy.BearController do

  alias Servy.{Bear, BearView, Conv, Wildthings}

  def index(%Conv{} = conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

      %Conv{ conv | status: 200, resp_body: BearView.index(bears) }
  end

  def new(%Conv{} = conv, _params) do
    %Conv{ conv | path: "/pages/form" }
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %Conv{ conv | status: 200, resp_body: BearView.show(bear) }
  end

  def delete(%Conv{} = conv, %{"id" => id}) do
    %Conv{ conv | status: 403, resp_body: "Deleting a bear #{id} is forbidden!"}
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %Conv{ conv | status: 201, resp_body: "Create a #{type} bear named #{name}!" }
  end
end
