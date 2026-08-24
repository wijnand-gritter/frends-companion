# HTTP Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Handles an incoming HTTP request at a route, without the full OpenAPI/API-management layer of the
[API Trigger](api.md). Use it for simple HTTP endpoints, webhooks, and callbacks.

## Configuration (confirmed keys)
`routeTemplate`, `httpMethod`, `allowedSchemes`, `auth`, `corsEnabled`, `allowedOrigins`, `isPrivate`.

## Expressions and references
Read the request through `#trigger` (e.g. `#trigger.data.httpBody`). For an immediate response while
the Process keeps working (e.g. before a [Checkpoint](../shapes/checkpoint.md)), use an
[Intermediate Return](../shapes/intermediate-return.md).

## Serialization
JSON `Type` 0, `SelectedTypeId: "HttpTrigger"`. Confirmed `config` keys: `routeTemplate`,
`allowedSchemes`, `auth`, `corsEnabled`, `allowedOrigins`, `httpMethod`, `isPrivate`. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/http-trigger.md`
