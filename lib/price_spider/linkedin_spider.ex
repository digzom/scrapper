defmodule LinkedinSpider do
  use Crawly.Spider
  @impl Crawly.Spider
  def base_url do
    "https://www.linkedin.com/"
  end

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.linkedin.com/jobs/search/?currentJobId=3278066482&geoId=106057199&keywords=elixir&location=Brasil&refresh=true"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} =
      response.body
      |> Floki.parse_document()

    # Getting search result urls
    urls =
      document
      |> Floki.find("div.s-result-list a.a-link-normal")
      |> Floki.attribute("href")

    # Convert URLs into requests
    requests =
      Enum.map(urls, fn url ->
        url
        |> build_absolute_url(response.request_url)
        |> Crawly.Utils.request_from_url()
      end)

    name =
      document
      |> Floki.find("span#productTitle")
      |> Floki.text()

    price =
      document
      |> Floki.find(".a-box-group span.a-price span.a-offscreen")
      |> Floki.text()
      |> String.trim_leading()
      |> String.trim_trailing()

    %Crawly.ParsedItem{
      requests: requests,
      items: [%{name: name, price: price, url: response.request_url}]
    }
  end

  def build_absolute_url(url, request_url) do
    URI.merge(request_url, url) |> to_string()
  end
end
