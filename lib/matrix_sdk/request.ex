defmodule MatrixSDK.Request do
  @moduledoc """
  Provides functions which return a struct containing the data necessary for
  each HTTP request.
  """

  @enforce_keys [:method, :base_url, :path]
  defstruct([:method, :base_url, :path, headers: [], body: %{}])

  @type method :: :head | :get | :delete | :trace | :options | :post | :put | :patch
  @type base_url :: binary
  @type path :: binary
  @type headers :: [{binary, binary}]
  @type body :: any

  @type t :: %__MODULE__{
          method: method,
          base_url: base_url,
          path: path,
          headers: headers,
          body: body
        }

  @type auth :: token :: binary | %{user: binary, password: binary}

  @doc """
  Returns a `%Request{}` struct used to get the versions of the Matrix specification
  supported by the server.

  ## Examples

      iex> MatrixSDK.Request.spec_versions("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/versions"
      }
  """
  @spec spec_versions(base_url) :: t
  def spec_versions(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/versions"}

  @doc """
  Returns a `%Request{}` struct used to get discovery information about the domain. 

  ## Examples

      iex> MatrixSDK.Request.server_discovery("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/.well-known/matrix/client"
      }
  """
  @spec server_discovery(base_url) :: t
  def server_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/.well-known/matrix/client"}

  @doc """
  Returns a `%Request{}` struct used to get the homeserver's supported login types to authenticate users. 

  ## Examples

      iex> MatrixSDK.Request.login("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :get,
        path: "/_matrix/client/r0/login"
      }
  """
  @spec login(base_url) :: t
  def login(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/r0/login"}

  @doc """
  Returns a `%Request{}` struct used to authenticate the user and issues an access token
  they can use to authorize themself in subsequent requests.

  ## Args

  - `base_url`: the base URL for the homeserver 
  - `auth`: either an authentication token or a map containing the `user` and `password` keys 
  - `opts`: an optional map containing the `device_id` and/or `initial_device_display_name` keys

  ## Examples
      
  Token authentication:

      iex> MatrixSDK.Request.login("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{token: "token", type: "m.login.token"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/login"
      }

  User and password authentication with optional parameters:

      iex> auth = %{user: "maurice_moss", password: "super-secure-password"}
      iex> opts = %{device_id: "device_id", initial_device_display_name: "THE INTERNET"}
      iex> MatrixSDK.Request.login("https://matrix.org", auth, opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          identifier: %{type: "m.id.user", user: "maurice_moss"},
          password: "super-secure-password",
          type: "m.login.password",
          device_id: "device_id",
          initial_device_display_name: "THE INTERNET"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/login"
      }
  """
  @spec login(base_url, auth, opts :: map) :: t
  def login(base_url, auth, opts \\ %{}) do
    body =
      auth
      |> login_auth()
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/login",
      body: body
    }
  end

  defp login_auth(token) when is_binary(token), do: %{type: "m.login.token", token: token}

  defp login_auth(%{user: username, password: password}),
    do: %{
      type: "m.login.password",
      identifier: %{
        type: "m.id.user",
        user: username
      },
      password: password
    }

  @doc """
  Returns a `%Request{}` struct used to invalidate an existing access token, so that it can no longer be used for authorization.

  ## Examples
      iex> MatrixSDK.Request.logout("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/logout"
      }
  """
  @spec logout(base_url, binary) :: t
  def logout(base_url, token), do: logout(base_url, "/_matrix/client/r0/logout", token)

  defp logout(base_url, path, token),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: path,
      headers: [{"Authorization", "Bearer " <> token}]
    }

  @doc """
  Returns a `%Request{}` struct used to invalidate all existing access tokens, so that they can no longer be used for authorization.

  ## Examples

      iex> MatrixSDK.Request.logout_all("https://matrix.org", "token")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [{"Authorization", "Bearer token"}],
        method: :post,
        path: "/_matrix/client/r0/logout/all"
      }
  """
  @spec logout_all(base_url, binary) :: t
  def logout_all(base_url, token), do: logout(base_url, "/_matrix/client/r0/logout/all", token)

  @doc """
  Returns a `%Request{}` struct used to register a guest account on the homeserver. 

  Note: all parameters in the request body with the exception of `initial_device_display_name` will be ignored by the homeserver.

  ## Examples

      iex> MatrixSDK.Request.register_guest("https://matrix.org")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register?kind=guest"
      }   

  Specifiying a display name for the device:    

      iex> opts = %{initial_device_display_name: "display name"}
      iex> MatrixSDK.Request.register_guest("https://matrix.org", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{initial_device_display_name: "display name"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register?kind=guest"
      }
  """
  @spec register_guest(base_url, map) :: t
  def register_guest(base_url, opts \\ %{}),
    do: %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register?kind=guest",
      body: opts
    }

  @doc """
  Returns a `%Request{}` struct used to register a user account on the homeserver. 

  ## Args

  ## Examples

      iex> MatrixSDK.Request.register_user("https://matrix.org", "password")
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{auth: %{type: "m.login.dummy"}, password: "password"},
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register"
      }

  With optional parameters:    

      iex> opts = %{
      ...>          username: "username",
      ...>          device_id: "id",
      ...>          initial_device_display_name: "display name",
      ...>          inhibit_login: true
      ...>        }
      iex> MatrixSDK.Request.register_user("https://matrix.org", "password", opts)
      %MatrixSDK.Request{
        base_url: "https://matrix.org",
        body: %{
          auth: %{type: "m.login.dummy"},
          device_id: "id",
          inhibit_login: true,
          initial_device_display_name: "display name",
          password: "password",
          username: "username"
        },
        headers: [],
        method: :post,
        path: "/_matrix/client/r0/register"
      }
  """
  @spec register_user(base_url, binary, map) :: t
  def register_user(base_url, password, opts \\ %{}) do
    body =
      password
      |> user_registration_auth()
      |> Map.merge(opts)

    %__MODULE__{
      method: :post,
      base_url: base_url,
      path: "/_matrix/client/r0/register",
      body: body
    }
  end

  defp user_registration_auth(password), do: %{auth: %{type: "m.login.dummy"}, password: password}

  def room_discovery(base_url),
    do: %__MODULE__{method: :get, base_url: base_url, path: "/_matrix/client/r0/publicRooms"}
end
