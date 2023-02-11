# transparent_http

[![Package Version](https://img.shields.io/hexpm/v/transparent_http)](https://hex.pm/packages/transparent_http)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/transparent_http/)

Simple HTTP Client for low level use cases

## Quick start
1. Add `transparent_http` and a http client which uses `gleam_http` types
```
gleam add transparent_http gleam_httpc
```

2. Create a client
```gleam
import transparent_http
import gleam/httpc


let client = transparent_http.default(httpc.send, "")
```

3. Send a request
```gleam
let res = client
|> transparent_http.req(fn (req) {
    req
    |> request.set_host("https://gleam.run")
    |> request.set_path("/health")
})
```
