# Task shape

**Category:** shape · **Baseline:** Frends 6.2/6.3

## Purpose
Runs a selected Frends [Task](../concepts/task.md) (HTTP Request, SQL, file read, transform, ...).
The bread-and-butter activity shape.

## Fields / configuration
After selecting the Task type, the parameter sidebar shows the Task's parameter groups (e.g.
`input`, `options`, `connection`, `cancellationToken`). Each leaf field is set to a mode —
Expression, Text, select, toggle, integer, json, sql, xml — see
[../expressions/field-types.md](../expressions/field-types.md). Fill only what you need; optional
fields fall back to defaults.

## Expressions and references
Reference a prior shape's output by display name: `#result[Task Name].Field` (e.g.
`#result[HTTP Request].Body`, `.StatusCode`). Confirm a Task's exact result fields from its tooltip
or source. See [../expressions/reference-syntax.md](../expressions/reference-syntax.md) and
[../expressions/task-definition-classes.md](../expressions/task-definition-classes.md).

## Serialization
BPMN `task`; JSON `Type` **1**; `SelectedTypeId` is the tenant-specific Task ref
`/ProcessTask/{guid}/v{n}` (**not portable** — harvest it, never fabricate). Parameters mirror the
Task's parameter classes as nested `{mode,value}` leaves. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md) and
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Retry on failure (built in, often overlooked)
Any Task shape can retry itself: `ShouldRetry: true` plus `MaxRetryCount` (up to 10) on the shape,
not inside the Parameters. **Retries fire on an exception only**, and the wait between attempts is
exponential: `500ms * 2^(retry count)`, so 1s, 2s, 4s, 8s, 16s, 32s and on up to 512s at ten tries.

This matters most for an HTTP Task, which by default returns a failing status as a *result* rather
than throwing, so shape retry never fires. Setting the HTTP Task's
`options.ThrowExceptionOnErrorResponse` to `true` turns a non-2xx response into an exception, and
the two together give rate-limit backoff with **no loop shapes at all**:

```
Task shape: ShouldRetry = true, MaxRetryCount = 5
options.ThrowExceptionOnErrorResponse = true
```

Prefer this over a hand-built [While](loop.md) retry loop, which costs five shapes per call site
(the While, its start and end, a sleep shape and a status-recording shape). Build the loop only
when the platform's policy is genuinely not enough, namely when you must honour a server's
`Retry-After` header, when you must pace proactively on a remaining-quota header, or when only
*some* statuses should be retried; `ThrowExceptionOnErrorResponse` throws on every non-2xx, so a
400 is retried as eagerly as a 429.

**Retry transient failures only** (timeouts, 429, 502, 503, 504, connection loss), on idempotent
operations, with a limited count: five by default. A validation or business error fails again
unchanged, so never retry it.

**Watch the 2xx that are not success.** Because the option keys off non-2xx, a `207 Multi-Status`
does not throw. Where 207 means partial failure (HubSpot batch endpoints), keep an explicit
positive status check in the shape that already reads the result, so partial failure cannot pass
as success.

## Gotchas
- **An imported retry setting may not show in the editor panel.** `ShouldRetry` and
  `MaxRetryCount` imported from a generated file have been observed reading as empty in the
  shape's retry panel while being present and correct in the file. Verify by exporting and
  reading the JSON, not by looking at the panel; a hand-set value and a generated one have
  been confirmed byte-identical.
- The Task GUID in `SelectedTypeId` differs per tenant and per package version — harvest from a real
  export.
- A Task's `Parameters` must include every parameter group from the method signature, not just the
  ones you changed.

## Example
HTTP Request "Get Customer": `url` (Expression) `$"https://crm/api/customers/{#var.order.CustomerId}"`,
`method` GET. Downstream: `#result[Get Customer].StatusCode == 200`.

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/task.md`; Task source on `FrendsPlatform`.
