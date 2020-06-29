defmodule Ueberauth.Strategy.Auth0.OAuthTest do
  use ExUnit.Case

  alias Ueberauth.Strategy.Auth0.OAuth

  import Mock

  @test_domain "example-app.auth0.com"

  setup do
    {:ok, %{client: OAuth.client()}}
  end

  test "creates correct client", %{client: client} do
    assert client.client_id == "clientidsomethingrandom"
    assert client.client_secret == "clientsecret-somethingsecret"
    assert client.redirect_uri == ""
    assert client.strategy == Ueberauth.Strategy.Auth0.OAuth
    assert client.authorize_url == "https://#{@test_domain}/authorize"
    assert client.token_url == "https://#{@test_domain}/oauth/token"
    assert client.site == "https://#{@test_domain}"
  end

  test "client options can be overriden" do
    client_id = :crypto.strong_rand_bytes(12)
    client_secret = :crypto.strong_rand_bytes(12)
    opts = [client_id: client_id, client_secret: client_secret]

    client = OAuth.client(opts)

    assert client.client_id == client_id
    assert client.client_secret == client_secret
  end

  test "authorize_url!/2 respects passed client options" do
    client_id = :crypto.strong_rand_bytes(12)
    client_secret = :crypto.strong_rand_bytes(12)
    opts = [client_id: client_id, client_secret: client_secret]

    url = OAuth.authorize_url!([], opts)

    assert url
           |> URI.parse()
           |> Map.get(:query)
           |> URI.decode_query()
           |> Map.get("client_id") == client_id
  end

  test "get_token!/2 respects passed client options" do
    with_mock OAuth2.Client, [:passthrough], get_token!: fn client, _, _, _ -> client end do
      client_id = :crypto.strong_rand_bytes(12)
      client_secret = :crypto.strong_rand_bytes(12)
      opts = [options: [client_options: [client_id: client_id, client_secret: client_secret]]]

      client = OAuth.get_token!([code: "abc"], opts)

      assert client.client_id == client_id
      assert client.client_secret == client_secret
    end
  end
end
