defmodule EliXero do

  def create_client(authorize_code) do
    authorize_code
    |> get_access_token()
    |> get_tenants()
    |> get_auth_event_id()
    |> get_tenant_id()
    |> do_create_client()
  end

  def renew_client(client) do
    response = EliXero.Public.renew_access_token(client.refresh_token)

    case response do
      %{"http_status_code" => 200}  ->
	%{client |
	  access_token: response["access_token"],
	  refresh_token: response["refresh_token"]}
      _                             -> response
    end 
  end


  defp get_access_token(authorize_code) do
    response = EliXero.Public.get_access_token(authorize_code)

    case response do
      %{"http_status_code" => 200}  -> {:ok, %{access_token: response["access_token"],
					      refresh_token: response["refresh_token"]}}
      _                             -> {:error, response}
    end 
  end

  defp get_tenants({:ok, %{access_token: access_token} = data}) do
    response = EliXero.Public.get_tenants(access_token)

    case response do
      %{"http_status_code" => 200}  -> {:ok, Map.put(data, :tenants, response["tenants"])}
      _                             -> {:error, response}
    end
  end
  defp get_tenants({:error, _error} = response), do: response

  defp get_auth_event_id({:ok, %{access_token: access_token} = data}) do
    [_header, payload, _signature] = String.split(access_token, ".")
    
    payload_data = payload
    |> Base.decode64!([padding: false])
    |> Poison.decode!()

    {:ok, Map.put(data, :auth_event_id, payload_data["authentication_event_id"])}
  end
  defp get_auth_event_id({:error, _error} = response), do: response

  defp get_tenant_id({:ok, %{tenants: tenants, auth_event_id: auth_event_id} = data}) do
    current_tenant = Enum.find(tenants, fn t -> t["authEventId"] == auth_event_id end)
    {:ok, Map.put(data, :tenant_id, current_tenant["tenantId"])}
  end
  defp get_tenant_id({:error, _error} = response), do: response

  defp do_create_client({:ok, %{access_token: access_token,
				tenant_id: tenant_id,
				refresh_token: refresh_token}}) do
			  
    %EliXero.Client{access_token: access_token, tenant_id: tenant_id, refresh_token: refresh_token}
  end
  defp do_create_client({:error, _error} = response), do: response
  
end
