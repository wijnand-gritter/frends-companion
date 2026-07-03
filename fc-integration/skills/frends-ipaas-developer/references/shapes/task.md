# Task shape

**Category:** shape · **Baseline:** Frends 6.2

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

## Gotchas
- The Task GUID in `SelectedTypeId` differs per tenant and per package version — harvest from a real
  export.
- A Task's `Parameters` must include every parameter group from the method signature, not just the
  ones you changed.

## Example
HTTP Request "Get Customer": `url` (Expression) `$"https://crm/api/customers/{#var.order.CustomerId}"`,
`method` GET. Downstream: `#result[Get Customer].StatusCode == 200`.

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/task.md`; Task source on `FrendsPlatform`.
