import Config

config :crawly,
  closespider_timeout: 10,
  concurrent_requests_per_domain: 5,
  pipelines: [
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "/tmp"}
  ],
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    Crawly.Middlewares.AutoCookiesManager,
    {Crawly.Middlewares.UserAgent,
     user_agents: [
       "Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.18"
     ]}
  ]
