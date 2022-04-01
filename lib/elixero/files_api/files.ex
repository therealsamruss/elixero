defmodule EliXero.FilesApi.Files do
  @resource "files"
  @api_type :files

  def upload(client, path_to_file, name) do
    EliXero.Public.upload_multipart(client.access_token, @resource, @api_type, path_to_file, name)
  end
end
