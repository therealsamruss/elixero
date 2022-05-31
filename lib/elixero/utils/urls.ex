defmodule EliXero.Utils.Urls do

  #urls
  @base_url "https://api.xero.com/"
  @authorize_url "https://login.xero.com/identity/connect/authorize"
  @access_token_url "https://identity.xero.com/connect/token"
  @revoke_token_url "https://identity.xero.com/connect/revocation"
  @tenants_url @base_url <> "connections"

  #api_types
  @core_api "api.xro/2.0/"
  @payroll_api "payroll.xro/1.0/"
  @files_api "files.xro/1.0/"
  @assets_api "assets.xro/1.0/"

  def authorize(opts \\ []) do
    validator = Keyword.get(opts, :validator, EliXero.Utils.Helpers.random_string(8))
    scope = Keyword.get(opts, :scope, []) ++ default_scope() |> Enum.uniq()
    authorize(validator, scope)
  end
  
  def authorize(validator, scope) do
    @authorize_url <> "?" <> authorize_params(validator, scope)
  end
  
  def access_token do
    @access_token_url
  end

  def revoke_token do
    @revoke_token_url
  end

  def tenants do
    @tenants_url
  end

  def api(resource, api_type) do
    api =
      case(api_type) do
        :core -> @core_api
        :payroll -> @payroll_api
        :files -> @files_api
        :assets -> @assets_api
      end

    @base_url <> api <> resource
  end

  def append_query_filters(url, query_filters) do
    query_param_string = Enum.map_join query_filters, "&", fn({key, value}) -> 
      encoded_value = URI.encode(value, &URI.char_unreserved?(&1))
      encoded_value = String.replace(encoded_value, "+", "%20") # Spaces must be %20 not +
      key <> "=" <> encoded_value 
    end

    url <> "?" <> query_param_string
  end
  
  defp authorize_params(validator, scope) do
    [
      {:response_type, "code"},
      {:client_id, Application.get_env(:elixero, :client_id)},
      {:redirect_uri, Application.get_env(:elixero, :callback_url)},
      {:scope, Enum.join(scope, " ")},
      {:state, validator}
    ]
    |> EliXero.Utils.Helpers.join_params_keyword(:base_string)
  end

  defp default_scope() do
    ["openid", "profile", "email", "accounting.transactions"]
  end
  
end
