defmodule EliXero do
  def get_request_token do
    response = EliXero.Public.get_request_token

    case response do
      %{"http_status_code" => 200}  -> Map.merge(response, %{"auth_url" => EliXero.Utils.Urls.authorize(response["oauth_token"])})
      _                             -> response
    end
  end  

  def create_client(request_token, verifier) do
    response = EliXero.Public.approve_access_token(request_token, verifier)

    case response do
      %{"http_status_code" => 200}  -> create_client response
      _                             -> response
    end 
  end

  def renew_client(client) do
    response = EliXero.Public.renew_access_token(client.access_token)

    case response do
      %{"http_status_code" => 200}  -> create_client response
      _                             -> response
    end 
  end

  defp create_client(access_token) do
    %EliXero.Client{access_token: access_token}
  end
end
