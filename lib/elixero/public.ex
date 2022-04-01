defmodule EliXero.Public do
  
  @www_form "application/x-www-form-urlencoded"
  @json "application/json"

  def get_access_token(authorize_code) do
    access_token_url = EliXero.Utils.Urls.access_token()
    body = EliXero.Utils.Auth.access_token_body(authorize_code)
    headers = [EliXero.Utils.Auth.basic_header(), {"Content-Type", @www_form}]
    
    {:ok, response} = HTTPoison.post(access_token_url, body, headers)

    resp = %{"http_status_code" => response.status_code}
    Poison.decode!(response.body) |> Map.merge(resp)
  end

  def get_tenants(access_token) do
    tenants_url = EliXero.Utils.Urls.tenants()
    headers = [EliXero.Utils.Auth.bearer_header(access_token), {"Content-Type", @json}]

    {:ok, response} = HTTPoison.get(tenants_url, headers)

    resp = %{"http_status_code" => response.status_code}
    %{"tenants" => Poison.decode!(response.body)} |> Map.merge(resp)
  end

  ### OAuth functions

  def get_request_token do
    callback_url = URI.encode(Application.get_env(:elixero, :callback_url), &URI.char_unreserved?(&1))
    request_token_url = EliXero.Utils.Urls.request_token
    header = EliXero.Utils.Oauth.create_auth_header("GET", request_token_url, [oauth_callback: callback_url], nil)
    response = EliXero.Utils.Http.get(request_token_url, header)

    resp = %{"http_status_code" => response.status_code}
    URI.decode_query(response.body) |> Map.merge(resp)
  end

  def approve_access_token(request_token, verifier) do
    access_token_url = EliXero.Utils.Urls.access_token
    header = EliXero.Utils.Oauth.create_auth_header("GET", access_token_url, [oauth_token: request_token["oauth_token"], oauth_verifier: verifier], request_token)
    response = EliXero.Utils.Http.get(access_token_url, header)

    resp = %{"http_status_code" => response.status_code}
    URI.decode_query(response.body) |> Map.merge(resp)
  end

  def renew_access_token(access_token) do
    access_token_url = EliXero.Utils.Urls.access_token
    header = EliXero.Utils.Oauth.create_auth_header("GET", access_token_url, [ oauth_token: access_token["oauth_token"], oauth_session_handle: access_token["oauth_session_handle"] ])
    response = EliXero.Utils.Http.get(access_token_url, header)

    resp = %{"http_status_code" => response.status_code}
    URI.decode_query(response.body) |> Map.merge(resp)
  end

  ### Api functions

  def find(client, resource, api_type) do
    url = EliXero.Utils.Urls.api(resource, api_type)
    headers = auth_headers(client)
    EliXero.Utils.Http.get(url, headers)
  end

  def find(client, resource, api_type, query_filters, extra_headers) do
    url = EliXero.Utils.Urls.api(resource, api_type) |> EliXero.Utils.Urls.append_query_filters(query_filters)
    headers = auth_headers(client)
    EliXero.Utils.Http.get(url, headers, extra_headers)
  end

  def create(client, resource, api_type, data_map) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    method =
      case(api_type) do
        :core -> "PUT"
      end

    headers = auth_headers(client)

    response =
      case(method) do
        "PUT" -> EliXero.Utils.Http.put(url, headers, data_map)
      end

    response
  end

  def update(client, resource, api_type, data_map) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    method =
      case(api_type) do
        :core -> "POST"
      end

    headers = auth_headers(client)

    response =
      case(method) do
        "POST" -> EliXero.Utils.Http.post(url, headers, data_map)
      end

    response
  end

  def delete(client, resource, api_type) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    headers = auth_headers(client)

    EliXero.Utils.Http.delete(url, headers)
  end

  def upload_multipart(client, resource, api_type, path_to_file, name) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    headers = auth_headers(client)

    EliXero.Utils.Http.post_multipart(url, headers, path_to_file, name)
  end

  def upload_attachment(client, resource, api_type, path_to_file, filename, include_online) do
    url = EliXero.Utils.Urls.api(resource, api_type)
    url_for_signing = url <> "/" <> String.replace(filename, " ", "%20") <> "?includeonline=" <> ( if include_online, do: "true", else: "false") # Spaces must be %20 not +
    headers = auth_headers(client)

    url = url <> "/" <> URI.encode(filename, &URI.char_unreserved?(&1)) <> "?includeonline=" <> ( if include_online, do: "true", else: "false")
    EliXero.Utils.Http.post_file(url, headers, path_to_file)
  end

  
  defp auth_headers(client) do
    bearer = client.access_token |> EliXero.Utils.Auth.bearer_header()
    tenant = client.tenant_id |> EliXero.Utils.Auth.tenant_header()
    [bearer, tenant]
  end
  
end
