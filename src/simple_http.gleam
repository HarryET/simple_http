import gleam/io
import gleam/http.{Get}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/option.{None, Option}
import gleam/dynamic.{Dynamic}

pub type SimpleHttpBuilder(req_body, res_body) {
  SimpleHttpBuilder(
    /// Function that is applied to the `base_request` before being passed
    /// to the `req` function
    setup_request: Option(fn(Request(req_body)) -> Request(req_body)),
    /// Base request for contant values e.g. auth headers
    base_request: Option(Request(req_body)),
    /// Initial value for request body, e.g. `""`
    initial_req_body: req_body,
    /// Function that sends a request and gets a response
    sender: fn(Request(req_body)) -> Response(res_body),
  )
}

pub type SimpleHttp(req_body, res_body) {
  SimpleHttp(
    setup_request: fn(Request(req_body)) -> Request(res_body),
    base_request: Request(req_body),
    sender: fn(Request(req_body)) -> Response(res_body),
  )
}

pub fn new_builder(
  sender: fn(Request(req_body)) -> Response(res_body),
  initial_request_body: req_body,
) -> SimpleHttpBuilder(req_body, res_body) {
  SimpleHttpBuilder(
    setup_request: None,
    base_request: None,
    sender: sender,
    initial_req_body: initial_request_body,
  )
}

/// Creates a default SimpleHttp client
pub fn default(
  sender: fn(Request(req_body)) -> Response(res_body),
  initial_request_body: req_body,
) -> SimpleHttp(req_body, res_body) {
  new(new_builder(sender, initial_request_body))
}

/// Creates a new SimpleHttp client, taking overrides from the
/// SimpleHttpBuilder
pub fn new(
  builder: SimpleHttpBuilder(req_body, res_body),
) -> SimpleHttp(req_body, res_body) {
  SimpleHttp(
    setup_request: option.unwrap(builder.setup_request, or: fn(r) { r }),
    base_request: option.unwrap(
      builder.base_request,
      Request(
        method: Get,
        headers: [],
        body: builder.initial_req_body,
        scheme: http.Https,
        host: "localhost",
        port: option.None,
        path: "",
        query: option.None,
      ),
    ),
    sender: builder.sender,
  )
}

/// Sends a request via the client's `sender`, the flow is as follows:
/// 1. Take client's `base_request`
/// 2. Pass to the `setup_request` function
/// 3. Pass to the `request` parameter
/// 4. Return the reponse from `sender`
pub fn req(
  client: SimpleHttp(req_body, res_body),
  request: fn(Request(req_body)) -> Request(res_body),
) {
  client.base_request
  |> client.setup_request
  |> request
  |> client.sender
}
