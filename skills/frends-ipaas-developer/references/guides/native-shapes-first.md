# Guide: native shapes first

Category: guide · Status: the companion's build default, a convention. An organisation's written
standard can override it. The platform limits at the end apply whatever the standard says.

Build the logic of a Process in Frends shapes and in data. A Code shape is the last resort, for one
action that no Task, shape or expression can do. Writing C# is fast and tidy, and that is the trap:
the diagram stays clean while the logic disappears from view.

The canvas is the documentation. The colleague on call opens a failed Process Instance and reads it
shape by shape, each with its own input and result. Logic inside a Code shape shows up as one box
with one result, and they have to read C# to find out which branch ran. A reviewer reads the
diagram, not 80 lines of code. A functional consultant can change a DMN table or an Environment
Variable without a developer and a new Process version.

An example. An order router written as one Code shape, `Process order`, checks the country with
`if`/`else`, maps status codes in a `switch`, posts to the ERP with `HttpClient` and throws when the
ERP refuses. Built natively, the same logic is an Exclusive Decision `Is the country supported`, a
DMN Task `Map order status`, an HTTP Request Task `Send order to ERP` with retry on the shape, and a
Throw `Order rejected by ERP`. Every step now shows in the Process Instance view, the status table
can change without touching code, and the HTTP call gets the Task's retry, logging and secret
fields.

## The order of choice

For each piece of logic, take the first option that fits:

1. A Task from the catalogue or the tenant, for every call to an outside system: HTTP, SQL, files,
   SFTP, mail, queues.
2. A native shape for the route through the Process: [Exclusive](../shapes/exclusive-decision.md)
   or [Inclusive Decision](../shapes/inclusive-decision.md), [Foreach or While](../shapes/loop.md),
   [Scope and Catch](../shapes/scope-and-catch.md), [Throw](../shapes/throw.md),
   [Return](../shapes/return.md), [Call Subprocess](../shapes/call-subprocess.md).
3. An [Assign Variable](../shapes/assign-variable.md) shape, to set or reshape one value with one
   expression, and on 6.4 a [Visual Data Mapper](../shapes/visual-data-mapper.md) to map one JSON
   structure onto another.
4. Data, for rules and constants: a [DMN Task](../shapes/dmn-task.md) for decision tables,
   [Environment Variables](../concepts/environment-variables.md) for values that differ per
   Environment, or a lookup source the business owns (a database table the Process reads with a
   Task).
5. A [Code shape](../shapes/code-task.md), for one action none of the above can express.
6. A [custom Task](../tasks/authoring.md), when the code needs a library Frends does not load or
   the same code is needed in several Processes. Reuse of a flow, rather than code, is a
   [Subprocess](../concepts/subprocess.md).

## Where each kind of logic goes

| Logic | Goes in | What a Code shape would hide |
| --- | --- | --- |
| Choosing a route on a value | Exclusive Decision; Inclusive Decision when several branches can run | which branch ran, and why |
| Iterating over records | Foreach or While, with named shapes in the body | per-item results; While's `maxIterations` safeguard |
| Calling HTTP, SQL, files, SFTP, mail | the dedicated Task, harvested from the tenant | the dependency, shape retry, Skip logging, secret fields |
| Retrying or waiting | retry on the Task shape; [Scheduled Resume](../shapes/scheduled-resume.md) for long waits | the attempts; a `Thread.Sleep` holds an Agent thread |
| Failing the run | a Throw shape, after a Decision | the failure path on the diagram |
| Setting a variable | Assign Variable | the value at that step |
| Code and value lists (status to status, country to warehouse) | DMN Task, or a lookup source | the business rule, and who may change it |
| Thresholds, endpoints, account ids | Environment Variables | the per-Environment values |
| A Task's input (headers, query parameters) | the Task's own fields, as Expression or Text | nothing, unless the fields cannot hold the structure |
| Mapping JSON onto another JSON model | on 6.4, a Visual Data Mapper; before 6.4, a transformation Task if the catalogue has one, otherwise one Code shape per mapping | the field mappings, which the mapper shows on the canvas |
| Mapping XML, CSV or fixed-width data | a Task for the format, then a Visual Data Mapper on the JSON; otherwise one Code shape per mapping | acceptable in a Code shape |

## What a Code shape is for

A Code shape holds one transformation or calculation that no Task, mapper or single expression
covers. Good examples: parsing a fixed-width file line into a `JObject`, computing a checksum the
target system requires, or, before 6.4, mapping an AFAS order to the HubSpot deal model. On 6.4 that
last one is a Visual Data Mapper.

Inside it:

- One action. If the shape name needs "and", split it.
- No calls to outside systems.
- No route decisions. The shape may compute a value, such as `isValid` or `targetSystem`; the
  Decision after it chooses the route.
- No `throw` for business failures. Return a status value, then decide on it and end in a Throw
  shape. A guard against malformed input that should never happen may throw.
- No `#var` assignments. Return the value and assign it through the shape's `variableName`.
- No hard-coded lists or constants that the business may change.

State in the design why the logic needs a Code shape, such as "no Task maps this structure". The
style for the C# itself is in [code-shape-style.md](code-shape-style.md).

For a Visual Data Mapper, the rules under "Data mapping" in [best-practices.md](best-practices.md)
apply: map from the payload, and keep one schema per model in one place.

## When the tools push towards code

- The file route generator, `generate_process.py`, emits linear flows of Tasks and Code shapes
  only. That limit is no reason to fold a Decision or a Loop into C#. Hand-author those shapes from
  the references, or build on the MCP route.
- A Task with no harvested export is no reason to re-implement it in a Code shape. Ask for a sample
  export ([generation-checklist.md](../process-file-format/generation-checklist.md)).
- On the MCP route every native shape has its own tool: `process_add_decision`,
  `process_add_foreach`, `process_add_while`, `process_add_dmn`, `process_add_throw`,
  `process_add_vdm` with `process_set_source_schema` (6.4), and `process_add_expression` for Assign
  Variable. The MCP `process-authoring` guide says to prefer a Code shape over an Expression shape
  for new code. That compares two kinds of C# shape; it does not override this order. See
  [mcp-build-conventions.md](mcp-build-conventions.md).

## Checked in review

`frends-reviewer` checks this in two rules. STR-03 (major) flags a Code shape that calls an outside
system. STR-04 (minor) flags `throw` statements, `#var` assignments, sleeps, value lists of five or
more literals and chains of three or more `else if`. STR-05 (info) flags a Code shape that builds a
JSON object field by field, a candidate for a Visual Data Mapper on 6.4. All three are heuristics: the reviewer confirms each
finding against the design, because a guard `throw` or a one-off mapping can be the right call.

## Platform limits that apply anyway

- A Code shape cannot load libraries or namespaces Frends has not loaded
  ([../expressions/code-tasks.md](../expressions/code-tasks.md)).
- All shapes compile into one class, so names collide across shapes
  ([code-shape-style.md](code-shape-style.md)).
- A loop inside a Code shape has no safeguard or cancellation; an endless one blocks the Agent
  ([../shapes/loop.md](../shapes/loop.md)).

## Sources

- `https://docs.frends.com/guides/general/frends-best-practices-collection.md` (prefer explicit
  shapes, a dedicated Task over generic code)
- `https://docs.frends.com/guides/development/using-dmn-task-in-frends-processes.md`
- `https://docs.frends.com/reference/shapes/activity-shapes/visual-data-mapper.md`
- The order of choice and the Code shape rules are this companion's convention.
