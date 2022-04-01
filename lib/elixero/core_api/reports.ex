defmodule EliXero.CoreApi.Reports do
  @api_type :core
  @resource "reports"
  @model_module EliXero.CoreApi.Models.Reports

  def find(client) do
    EliXero.CoreApi.Common.find(client, @resource)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def named(client, name) do
    resource = @resource <> "/" <> name

    EliXero.Public.find(client.access_token, resource, @api_type)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def named(client, name, filter) do
    resource = @resource <> "/" <> name <> "?" <> filter

    EliXero.Public.find(client.access_token, resource, @api_type)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def individual_report(client, identifier) do
    resource = @resource <> "/" <> identifier

    EliXero.Public.find(client.access_token, resource, @api_type)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end
end
