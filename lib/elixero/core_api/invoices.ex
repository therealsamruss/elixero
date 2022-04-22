defmodule EliXero.CoreApi.Invoices do
  @api_type :core
  @resource "invoices"
  @model_module EliXero.CoreApi.Models.Invoices
  @online_invoices_model_module EliXero.CoreApi.Models.OnlineInvoices

  def find(client) do
    EliXero.CoreApi.Common.find(client, @resource)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def find(client, identifier) do
    EliXero.CoreApi.Common.find(client, @resource, identifier)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def filter(client, filter) do
    EliXero.CoreApi.Common.filter(client, @resource, filter)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def create(client, invoices_map) do
    EliXero.CoreApi.Common.create(client, @resource, invoices_map)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def update(client, identifier, invoices_map) do
    EliXero.CoreApi.Common.update(client, @resource, identifier, invoices_map)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@model_module)
  end

  def online_invoice_url(client, identifier) do
    resource = @resource <> "/" <> identifier <> "/OnlineInvoice"

    EliXero.Public.find(client, resource, @api_type)
    |> EliXero.CoreApi.Utils.ResponseHandler.handle_response(@online_invoices_model_module)
  end
end
