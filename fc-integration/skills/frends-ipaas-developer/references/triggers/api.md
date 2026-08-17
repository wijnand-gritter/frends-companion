# API Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Backs a full **API-managed** endpoint defined by an OpenAPI specification (see
[../concepts/api-management.md](../concepts/api-management.md)). The Process is the implementation
behind the endpoint, secured by API Policies.

## One API Trigger per process
A process accepts **at most one API Trigger** (editor-enforced). One OpenAPI operation binds to
one process; an API with N operations needs N processes. Consolidating operations into a single
process requires consolidating them into a single operation in the spec (e.g. a parameterised
path), which trades per-endpoint schema precision for process count - decide deliberately.

## Spec constraints
The OpenAPI document must satisfy Frends-specific rules beyond generic OpenAPI validity:
flat schemas with explicit `properties` (no `allOf` compositions), no YAML anchors/aliases,
concrete response status codes. Violations fail spec validation or trigger activation with
non-obvious errors. Full rules and the symptom table:
[openapi-spec-constraints.md](openapi-spec-constraints.md).

## Configuration (confirmed keys)
`routeTemplate`, `httpMethod`, `isPrivate`, `corsEnabled`, `allowedOrigins`, `allowedSchemes`,
`references` (the `#trigger.data.*` paths exposed for auto-complete, derived from the OpenAPI
request body's `properties`), and `openApiDocument` (the OpenAPI contract embedded as a string).

## Expressions and references
Read the request through `#trigger` (e.g. `#trigger.data.body.employeeId`). Return responses with a
[Return](../shapes/return.md) / [Throw](../shapes/throw.md) using `SelectedTypeId: "HttpResult"`.

## Serialization
JSON `Type` 0, `SelectedTypeId: "HttpApiTrigger"`. The full confirmed `config` (with `references` and
embedded `openApiDocument`) is in
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md);
see also [../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md)
and the bundled `examples/api_process_http_trigger_6.2.json`.

## New in 6.3
OpenAPI support is updated to **3.1.1**, the spec can carry **mTLS (client certificate)**
authentication options, and client certificate validation defaults to enabled on the
Cross-platform Agent. The flat-schema and no-anchor constraints below were confirmed on
6.2/6.3; revalidate against the live editor if a spec depends on 3.1-only constructs.

## Source of truth
`https://docs.frends.com/reference/triggers/api-trigger.md`
