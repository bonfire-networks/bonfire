defmodule Bonfire.Web.FakeRemoteEndpoint do
  use Phoenix.Endpoint, otp_app: :bonfire
  use Bonfire.UI.Common.EndpointTemplate

  plug(Bonfire.Web.Router)

  defdelegate include_assets(conn), to: Bonfire.Web.Endpoint
  defdelegate include_assets(conn, section), to: Bonfire.Web.Endpoint
end
