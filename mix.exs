defmodule EliXero.Mixfile do
  use Mix.Project

  def project do
    [app: :elixero,
     version: "0.1.1",
     elixir: "~> 1.13",
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:poison, "~> 3.0"},
      {:ecto, "~> 3.7.2"}
    ]
  end

  defp description do
    """
    Xero API elixir SDK
    """
  end

  defp package do
    [
      maintainers: ["muszbek"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/muszbek/elixero"}
    ]
  end
end
