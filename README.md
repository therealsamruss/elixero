# EliXero

Xero deprecated OAuth1 in 2021, and the original Elixero repository became obsolete. This fork is adapting Elixero to conform with the new authentication protocol with Xero.  
Private public and partner application types have been removed, there is only one way to authenticate now.

## Usage instructions

In order to use this SDK, you will need to have created an application in the [developer portal](https://app.xero.com).
Once you've created your application you'll reach a config section that stores your client id and secret, as well as some other details.

As the config section will hold sensitive data, it's recommended that you create a seperate config file which is not stored in version control, and then import the new config file into your applications overall config file.  
The config section will need to look something like this:

```
config :elixero,
  client_id: "your_applications_client_id",
  client_secret: "your_applications_client_secret",
  callback_url: "callback_url"
```

* client_id - client id found in the overview page of your application on the developer portal
* client_secret - client secret found in the overview page of your application on the developer portal
* callback_url - set to the url you want to be called back into after the user autorises the connection for an organisation

Note: make sure you included the callback url in your application configuration on the developer portal under "Redirect URIs"!

The application must be authorized in a browser in order to be able to request an access token and call the API. You can find more information about the authorization workflow here:  
https://developer.xero.com/documentation/guides/oauth2/auth-flow

Once you have set up your config file you can use your application with Phoenix like so:

1. Create a controller with an endpoint that redirects to the authorization url of Xero:

```
defmodule MyApp.AuthController do
  use MyAppWeb, :controller
  
  def authorize(conn, _params) do
    url = EliXero.Utils.Urls.authorize()
    redirect(conn, external: url)
  end
end
```

2. Add a callback endpoint in the same controller, that takes a "code" parameter in the HTTP request, and authenticates the client:

```
  def auth_callback(conn, %{"code" => code}) do
    client = EliXero.create_client(code)
    #TODO: store client in database or cookie
    
    conn
    |> put_flash(:info, "Authorization received from Xero.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
```

3. Add routes:

```
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WbAdminWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyAppWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/auth", AuthController, :authorize
    get "/callback", AuthController, :auth_callback
  end
```

Note: the callback path has to conform with your callback_url in the config and what you set on the Xero developer portal!

4. The returned *client* structure looks as such:

```
%EliXero.Client{
  access_token: "a_long_JWS_token_string",
  refresh_token: "another_shorter_token_string",
  tenant_id: "another_string_that_is_constant"
}
```

Store these data in a database or session cookie so you can fetch it when you want to make an API call.

5. Renew the tokens:

```
client = EliXero.renew_client(client_from_database)
```

You will have to do it every 30 minutes in a periodic background job in order to keep your tokens valid. Otherwise you need to fetch new tokens with the above mentioned authorization process, which involves a manual click in the browser prompt.

6. Access the API:

```
client = EliXero.create_client(access_token_from_db, refresh_token_from_db, tenant_id_from_db)

EliXero.CoreApi.Invoices.find(client)
```


## Use of filter functions

Some endpoints allow various filter methods when retrieving information from the Xero API. 
All filtering, with the exception of if-modified-since, is performed via query parameters. If-modified-since is done via a header.

When using filtering, a map outlining what filtering you want needs to be supplied.

Below is an example on how to do this when you want to retrieve all DRAFT, ACCREC invoices, ordered by Date desc, modified since the start of 2017:

```
filter = %{:query_filters => [{"where", "Status==\"DRAFT\" AND Type==\"ACCREC\""}, {"orderby", "Date desc"}], :modified_since => "2017-01-01" }

EliXero.CoreApi.Invoices.filter client, filter
```

You do not need to supply both :query_filters and :modified_since if you only want to filter by one of them.

## Installation

  1. Add `elixero` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:elixero, git: "https://github.com/muszbek/elixero"}]
    end
    ```

  2. Ensure `elixero` is started before your application:

    ```elixir
    def application do
      [applications: [:elixero]]
    end
    ```

