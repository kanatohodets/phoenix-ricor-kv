defmodule Pingring.StoreView do
  require Logger
  use Pingring.Web, :view
  def render("store.json", %{store: store_result}) do
    Logger.warn("a view! with store! #{inspect store_result}")
    {:ok, store_results} = store_result
    store_list = Enum.map(store_results, fn({x}) -> x end)
    %{data: store_list}
  end

  def render("fetch.json", %{:fetch => :not_found}) do
    Logger.warn("a view! with fetch not found")
    %{:data => :not_found}
  end

  def render("fetch.json", %{fetch: data}) do
    Logger.warn("a view! with fetch #{inspect data}")
    %{data: data}
  end

end
