defmodule EliXero.Utils.Auth do

  def basic_header() do
    key = Application.get_env(:elixero, :client_id)
    secret = Application.get_env(:elixero, :client_secret)
    code = Base.encode64(key <> ":" <> secret)
    {"Authorization", "Basic " <> code}
  end

  def bearer_header(token) do
    {"Authorization", "Bearer " <> token}
  end

  def access_token_body(authorize_code) do
    [
      {:grant_type, "authorization_code"},
      {:code, authorize_code},
      {:redirect_uri, Application.get_env(:elixero, :callback_url)}
    ]
    |> EliXero.Utils.Helpers.join_params_keyword(:base_string)
  end
end
