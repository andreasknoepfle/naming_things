defmodule NamingThings.PageController do
  use NamingThings.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
