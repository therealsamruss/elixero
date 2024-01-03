defmodule EliXero do

  def create_client(authorize_code) when is_binary(authorize_code) do
    authorize_code
    |> get_access_token()
    |> get_tenants()
    |> get_auth_event_id()
    |> get_tenant_id()
    |> do_create_client()
  end

  def create_client(%{access_token: _at, refresh_token: _rt, tenant_id: _ti} = map) do
    struct(EliXero.Client, map)
  end

  def create_client(access_token, refresh_token, tenant_id) do
    %EliXero.Client{access_token: access_token, tenant_id: tenant_id, refresh_token: refresh_token}
  end

  def renew_client(%EliXero.Client{} = client) do
    response = EliXero.Public.renew_access_token(client.refresh_token)

    case response do
      %{"http_status_code" => 200}  ->
	%{client |
	  access_token: response["access_token"],
	  refresh_token: response["refresh_token"]}
      _                             -> response
    end
  end

  def renew_client(refresh_token) do
    response = EliXero.Public.renew_access_token(refresh_token)

    case response do
      %{"http_status_code" => 200}  ->
	      {:ok, %{
          access_token: response["access_token"],
          refresh_token: response["refresh_token"]
        }}
        |> get_tenants()
        |> get_auth_event_id()
        |> get_tenant_id()
        |> do_create_client()
      _ -> response
    end
  end

  def revoke_client(client) do
    response = EliXero.Public.revoke_token(client.refresh_token)

    case response do
      %{"http_status_code" => 200}  -> {:ok, client}
      _                             -> {:error, response}
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
    case Enum.find(tenants, fn t -> t["authEventId"] == auth_event_id end) do
      nil ->
        if Enum.empty?(tenants) do
          {:error, %{error: "No tenant found."}}
        else
          current_tenant = tenants |> hd()
          {:ok, Map.put(data, :tenant_id, current_tenant["tenantId"])}
        end
      current_tenant -> {:ok, Map.put(data, :tenant_id, current_tenant["tenantId"])}
    end
  end
  defp get_tenant_id({:error, _error} = response), do: response

  defp do_create_client({:ok, %{access_token: access_token,
				tenant_id: tenant_id,
				refresh_token: refresh_token}}) do
			  
    create_client(access_token, refresh_token, tenant_id)
  end
  defp do_create_client({:error, _error} = response), do: response
  
end
