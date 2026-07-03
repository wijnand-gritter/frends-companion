# API Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Backs a full **API-managed** endpoint defined by an OpenAPI specification (see
[../concepts/api-management.md](../concepts/api-management.md)). The Process is the implementation
behind the endpoint, secured by API Policies.

## Configuration (confirmed keys)
`routeTemplate`, `httpMethod`, `isPrivate`, `corsEnabled`, `allowedOrigins`, `allowedSchemes`,
`references` (the `#trigger.data.*` paths exposed for auto-complete, derived from the OpenAPI body),
and `openApiDocument` (the OpenAPI contract embedded as a string).

## Expressions and references
Read the request through `#trigger` (e.g. `#trigger.data.body.employeeId`). Return responses with a
[Return](../shapes/return.md) / [Throw](../shapes/throw.md) using `SelectedTypeId: "HttpResult"`.

## Serialization
JSON `Type` 0, `SelectedTypeId: "HttpApiTrigger"`. The full confirmed `config` (with `references` and
embedded `openApiDocument`) is in
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md);
see also [../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md)
and the bundled `examples/api_process_http_trigger_6.2.json`.

## Source of truth
`https://docs.frends.com/reference/triggers/api-trigger.md`
