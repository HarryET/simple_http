// Copyright 2023 Harry Bairstow
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import gleam/http.{Get}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/option.{None, Option}

pub type TransparentHttpBuilder(body, error) {
  TransparentHttpBuilder(
    /// Function that is applied to the `base_request` before being passed
    /// to the `req` function
    setup_request: Option(fn(Request(body)) -> Request(body)),
    /// Base request for contant values e.g. auth headers
    base_request: Option(Request(body)),
    /// Initial value for request body, e.g. `""`
    initial_req_body: body,
    /// Function that sends a request and gets a response
    sender: fn(Request(body)) -> Result(Response(body), error),
  )
}

pub type TransparentHttp(body, error) {
  TransparentHttp(
    setup_request: fn(Request(body)) -> Request(body),
    base_request: Request(body),
    sender: fn(Request(body)) -> Result(Response(body), error),
  )
}

pub fn new_builder(
  sender: fn(Request(body)) -> Result(Response(body), error),
  initial_request_body: body,
) -> TransparentHttpBuilder(body, error) {
  TransparentHttpBuilder(
    setup_request: None,
    base_request: None,
    sender: sender,
    initial_req_body: initial_request_body,
  )
}

/// Creates a default TransparentHttp client
pub fn default(
  sender: fn(Request(body)) -> Result(Response(body), error),
  initial_request_body: body,
) -> TransparentHttp(body, error) {
  new(new_builder(sender, initial_request_body))
}

/// Creates a new TransparentHttp client, taking overrides from the
/// TransparentHttpBuilder
pub fn new(
  builder: TransparentHttpBuilder(body, error),
) -> TransparentHttp(body, error) {
  TransparentHttp(
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
  client: TransparentHttp(body, error),
  request: fn(Request(body)) -> Request(body),
) -> Result(Response(body), error) {
  client.base_request
  |> client.setup_request
  |> request
  |> client.sender
}
