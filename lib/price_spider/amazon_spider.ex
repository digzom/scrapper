defmodule AmazonSpider do
  use Crawly.Spider
  @impl Crawly.Spider
  def base_url do
    "http://www.amazon.com"
  end

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.amazon.com/s?k=3080+video+card&rh=n%3A17923671011%2Cn%3A284822&dc&qid=1650819793&rnid=2941120011&sprefix=3080+video%2Caps%2C107&ref=sr_nr_n_2"
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

  def get_session_cookie(username, password) do
    action_url =
      "https://www.linkedin.com/login?emailAddress=&fromSignIn=&fromSignIn=true&session_redirect=https%3A%2F%2Fwww.linkedin.com%2Fjobs%2Fsearch%2F%3FcurrentJobId%3D2884089192%26geoId%3D106057199%26keywords%3Delixir%26location%3DBrasil%26refresh%3Dtrue%26position%3D1%26pageNum%3D0&trk=public_jobs_nav-header-signin"

    response = Crawly.fetch(action_url)

    # Extract cookie from headers
    {{"Set-Cookie", cookie}, _headers} = List.keytake(response.headers, "Set-Cookie", 0)

    # Extract CSRF token from body
    {:ok, document} = Floki.parse_document(response.body)

    csrf =
      document
      |> Floki.find("form.login__form input[name='csrfToken']")
      |> Floki.attribute("value")
      |> Floki.text()

    # Prepare and send the request. The given login form accepts any
    # login/password pair
    req_body =
      %{
        "username" => username,
        "password" => password,
        "csrfToken" => csrf
      }
      |> URI.encode_query()

    {:ok, login_response} =
      HTTPoison.post(action_url, req_body, %{
        "Content-Type" => "application/x-www-form-urlencoded",
        "Cookie" => cookie
      })

    {{"Set-Cookie", session_cookie}, _headers} =
      List.keytake(login_response.headers, "Set-Cookie", 0)

    session_cookie
  end
end
