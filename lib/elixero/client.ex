defmodule EliXero.Client do
  @derive Jason.Encoder
  defstruct [:access_token, :tenant_id, :refresh_token]
end
