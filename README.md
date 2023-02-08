# simple_http

[![Package Version](https://img.shields.io/hexpm/v/simple_http)](https://hex.pm/packages/simple_http)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/simple_http/)

Simple HTTP Client for low level use cases

## Quick start
1. Add simple_http and a http client which uses `gleam_http` types
```
gleam add simple_http gleam_httpc
```

2. Create a client
```gleam
import simple_http
import gleam/httpc


let client = simple_http.default(httpc.send, "")
```

3. Send a request
```gleam
let res = client
|> simple_http.req(fn (req) {
    req
    |> request.set_host("https://gleam.run")
    |> request.set_path("/health")
})
```

## Installation

If available on Hex this package can be added to your Gleam project:

```sh
gleam add simple_http
```

and its documentation can be found at <https://hexdocs.pm/simple_http>.
