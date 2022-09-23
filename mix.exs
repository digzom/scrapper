defmodule PriceSpider.MixProject do
  use Mix.Project

  def project do
    [
      app: :price_spider,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PriceSpider.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crawly, "~> 0.14.0"},
      {:floki, "~> 0.33.0"},
      {:html5ever, "~> 0.13.0"}
    ]
  end
end
