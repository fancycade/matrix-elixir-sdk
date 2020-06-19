defmodule MatrixSDK.API do
  @moduledoc """
  Provides functions to make HTTP requests to a Matrix homeserver using the
  `MatrixSDK.Request` and `MatrixSDK.HTTPClient` modules.
  """

  alias MatrixSDK.{Request, HTTPClient, Auth}

  @http_client Application.get_env(:matrix_sdk, :http_client)

  @doc """
  Gets the versions of the Matrix specification supported by the server.  

  ## Examples

      MatrixSDK.API.spec_versions("https://matrix.org")
  """
  @spec spec_versions(Request.base_url()) :: HTTPClient.result()
  def spec_versions(base_url) do
    base_url
    |> Request.spec_versions()
    |> @http_client.do_request()
  end

  @doc """
  Gets discovery information about the domain. 

  ## Examples

      MatrixSDK.API.server_discovery("https://matrix.org")
  """
  @spec server_discovery(Request.base_url()) :: HTTPClient.result()
  def server_discovery(base_url) do
    base_url
    |> Request.server_discovery()
    |> @http_client.do_request()
  end

  @doc """
  Gets information about the server's supported feature set and other relevant capabilities.

  ## Examples

      MatrixSDK.API.server_capabilities("https://matrix.org", "token")
  """
  @spec server_capabilities(Request.base_url(), binary) :: HTTPClient.result()
  def server_capabilities(base_url, token) do
    base_url
    |> Request.server_capabilities(token)
    |> @http_client.do_request()
  end

  @doc """
  Gets the homeserver's supported login types to authenticate users. 

  ## Examples

      MatrixSDK.API.login("https://matrix.org")
  """
  @spec login(Request.base_url()) :: HTTPClient.result()
  def login(base_url) do
    base_url
    |> Request.login()
    |> @http_client.do_request()
  end

  @doc """
  Authenticates the user, and issues an access token they can use to authorize themself in subsequent requests.

  ## Examples

  Token authentication:

      auth = MatrixSDK.Auth.login_token("token")
      MatrixSDK.API.login("https://matrix.org", auth)

  User and password authentication with optional parameters:

      auth = MatrixSDK.Auth.login_user("maurice_moss", "password")
      opts = %{device_id: "id", initial_device_display_name: "THE INTERNET"}

      MatrixSDK.API.login("https://matrix.org", auth, opts)
  """
  @spec login(Request.base_url(), Auth.t(), opts :: map) :: HTTPClient.result()
  def login(base_url, auth, opts \\ %{}) do
    base_url
    |> Request.login(auth, opts)
    |> @http_client.do_request()
  end

  @doc """
  Invalidates an existing access token, so that it can no longer be used for authorization.

  ## Examples

      MatrixSDK.API.logout("https://matrix.org", "token")
  """
  @spec logout(Request.base_url(), binary) :: HTTPClient.result()
  def logout(base_url, token) do
    base_url
    |> Request.logout(token)
    |> @http_client.do_request()
  end

  @doc """
  Invalidates all existing access tokens, so that they can no longer be used for authorization.

  ## Examples

      MatrixSDK.API.logout_all("https://matrix.org", "token")
  """
  @spec logout_all(Request.base_url(), binary) :: HTTPClient.result()
  def logout_all(base_url, token) do
    base_url
    |> Request.logout_all(token)
    |> @http_client.do_request()
  end

  @doc """
  Registers a guest account on the homeserver. 

  ## Examples

      MatrixSDK.API.register_guest("https://matrix.org")

  Specifiying a display name for the device:    

      opts = %{initial_device_display_name: "THE INTERNET"}
      MatrixSDK.API.register_guest("https://matrix.org", opts)
  """
  @spec register_guest(Request.base_url(), map) :: HTTPClient.result()
  def register_guest(base_url, opts \\ %{}) do
    base_url
    |> Request.register_guest(opts)
    |> @http_client.do_request()
  end

  @doc """
  Registers a user account on the homeserver. 

  ## Examples

      MatrixSDK.API.register_user("https://matrix.org", "password")

  With optional parameters:    

      opts = %{
                username: "maurice_moss",
                device_id: "id",
                initial_device_display_name: "THE INTERNET",
                inhibit_login: true
              }

      MatrixSDK.API.register_user("https://matrix.org", "password", opts)
  """
  @spec register_user(Request.base_url(), binary, map) :: HTTPClient.result()
  def register_user(base_url, password, opts \\ %{}) do
    base_url
    |> Request.register_user(password, opts)
    |> @http_client.do_request()
  end

  @doc """
  Checks the given email address is not already associated with an account on the homeserver.

  ## Examples

        MatrixSDK.API.register_email("https://matrix.org", "secret", "maurice@moss.yay", 1)
  """
  @spec register_email(Request.base_url(), binary, binary, pos_integer, map) ::
          HTTPClient.result()
  def register_email(base_url, client_secret, email, send_attempt, opts \\ %{}) do
    base_url
    |> Request.register_email(client_secret, email, send_attempt, opts)
    |> @http_client.do_request()
  end

  @doc """
  Checks if a username is available and valid for the server.

  ## Examples

       MatrixSDK.API.username_availability("https://matrix.org", "maurice_moss")
  """
  @spec username_availability(Request.base_url(), binary) :: HTTPClient.result()
  def username_availability(base_url, username) do
    base_url
    |> Request.username_availability(username)
    |> @http_client.do_request()
  end

  @doc """
  Changes the password for an account on the homeserver.

  ## Examples 

      auth = MatrixSDK.Auth.login_token("token")
      MatrixSDK.API.change_password("https://matrix.org", "new_password", auth)
  """
  @spec change_password(Request.base_url(), binary, Auth.t(), map) :: HTTPClient.result()
  # REVIEW: This requires m.login.email.identity 
  def change_password(base_url, new_password, auth, opts \\ %{}) do
    base_url
    |> Request.change_password(new_password, auth, opts)
    |> @http_client.do_request()
  end

  @doc """
  Gets a list of the third party identifiers the homeserver has associated with the user's account.

  ## Examples

      MatrixSDK.API.account_3pids("https://matrix.org", "token")
  """
  @spec account_3pids(Request.base_url(), binary) :: HTTPClient.result()
  def account_3pids(base_url, token) do
    base_url
    |> Request.account_3pids(token)
    |> @http_client.do_request()
  end

  @spec account_add_3pid(Request.base_url(), Auth.t(), binary, binary, binary) ::
          HTTPClient.result()
  def account_add_3pid(base_url, auth, client_secret, sid, token) do
    base_url
    |> Request.account_add_3pid(auth, client_secret, sid, token)
    |> @http_client.do_request()
  end

  @doc """
  Gets information about the owner of a given access token.

  ## Examples

      MatrixSDK.API.whoami("https://matrix.org", "token")
  """
  @spec whoami(Request.base_url(), binary) :: HTTPClient.result()
  def whoami(base_url, token) do
    base_url
    |> Request.whoami(token)
    |> @http_client.do_request()
  end

  @doc """
  Synchronises the client's state with the latest state on the server.

  ## Examples 
      
      MatrixSDK.API.sync("https://matrix.org", "token")

  With optional parameters:

      opts = %{
                since: "s123456789",
                filter: "filter",
                full_state: true,
                set_presence: "online",
                timeout: 1000
              }

      MatrixSDK.API.sync("https://matrix.org", "token", opts)
  """
  @spec sync(Request.base_url(), binary, map) :: HTTPClient.result()
  def sync(base_url, token, opts \\ %{}) do
    base_url
    |> Request.sync(token, opts)
    |> @http_client.do_request()
  end

  @doc """
  Gets a single event based on `room_id` and `event_id`.

  ## Example

      MatrixSDK.API.room_event("https://matrix.org", "token", "!someroom:matrix.org", "$someevent")
  """
  @spec room_event(Request.base_url(), binary, binary, binary) :: HTTPClient.result()
  def room_event(base_url, token, room_id, event_id) do
    base_url
    |> Request.room_event(token, room_id, event_id)
    |> @http_client.do_request()
  end

  @doc """
  Looks up the contents of a state event in a room.

  ## Example

      MatrixSDK.API.room_state_event("https://matrix.org", "token", "!someroom:matrix.org", "m.room.member", "@user:matrix.org")
  """
  @spec room_state_event(Request.base_url(), binary, binary, binary, binary) ::
          HTTPClient.result()
  def room_state_event(base_url, token, room_id, event_type, state_key) do
    base_url
    |> Request.room_state_event(token, room_id, event_type, state_key)
    |> @http_client.do_request()
  end

  @doc """
  Gets the state events for the current state of a room.

  ## Example 

      MatrixSDK.API.room_state("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec room_state(Request.base_url(), binary, binary) :: HTTPClient.result()
  def room_state(base_url, token, room_id) do
    base_url
    |> Request.room_state(token, room_id)
    |> @http_client.do_request()
  end

  @doc """
  Gets the list of members for this room.

  ## Example 

      MatrixSDK.API.room_members("https://matrix.org", "token", "!someroom:matrix.org")

  With optional parameters:

      opts = %{
                at: "t123456789",
                membership: "join",
                not_membership: "invite"
              }

      MatrixSDK.API.room_members("https://matrix.org", "token", "!someroom:matrix.org", opts)
  """
  @spec room_members(Request.base_url(), binary, binary, map) :: HTTPClient.result()
  def room_members(base_url, token, room_id, opts \\ %{}) do
    base_url
    |> Request.room_members(token, room_id, opts)
    |> @http_client.do_request()
  end

  @doc """
  Gets a map of MXIDs to member info objects for members of the room.

  ## Example 

      MatrixSDK.API.room_joined_members("https://matrix.org", "token", "!someroom:matrix.org")
  """
  @spec room_joined_members(Request.base_url(), binary, binary) :: HTTPClient.result()
  def room_joined_members(base_url, token, room_id) do
    base_url
    |> Request.room_joined_members(token, room_id)
    |> @http_client.do_request()
  end

  @doc """
  Gets message and state events for a room. 
  It uses pagination query parameters to paginate history in the room.

  ## Example 

      MatrixSDK.API.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f")

  With optional parameters:

      opts = %{
                to: "t123456789",
                limit: 10,
                filter: "filter"
              }

      MatrixSDK.API.room_messages("https://matrix.org", "token", "!someroom:matrix.org", "t123456789", "f", opts)
  """
  @spec room_messages(Request.base_url(), binary, binary, binary, binary, map) ::
          HTTPClient.result()
  def room_messages(base_url, token, room_id, from, dir, opts \\ %{}) do
    base_url
    |> Request.room_messages(token, room_id, from, dir, opts)
    |> @http_client.do_request()
  end

  # REVIEW: this works on matrix.org but not on local?
  def room_discovery(base_url) do
    base_url
    |> Request.room_discovery()
    |> @http_client.do_request()
  end
end
