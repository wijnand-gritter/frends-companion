# Signal Resume shape

**Category:** shape (long-running) · **Baseline:** Frends 6.2

## Purpose
Resumes **another** paused Process by sending a signal with a matching Correlation ID. Lets you keep
polling/webhook logic in a separate Process while a [Checkpoint](checkpoint.md)-paused Long Running
Process stays simple.

## Fields / configuration
- **Correlation ID** — the value set on the target Process's Checkpoint to resume. If no paused
  Process matches, the shape throws (catch it or the Process fails). There is no built-in list of
  active correlation IDs — track them via [Shared State](shared-state-task.md) or an external system.

## Behavior
The shape's effect is on the *other* Process Instance, not the current one. The Agent looks up the
paused state by Correlation ID and resumes it from its Checkpoint. Paused Processes resume on the
same Agent they started on.

## Placement and gotchas
- It can sit anywhere between the trigger and a Return, and usually lives in a different Process
  from the paused one, such as an HTTP-triggered callback. It does not make its own Process wait:
  for that, use a [Checkpoint](checkpoint.md) with "Continue execution" off.
- It produces no result for the next shape. A bare `#result` straight after it (in a Return, Code
  or Assign shape) has nothing to read and fails to compile with `Cannot use a #-reference if isn't
  declared yet, or if there is no previous step.` Reference the shape you mean instead, such as
  `#result[Get order]` or `#var.order`. This looks like a placement problem: directly after the
  trigger the shape works because the next shape does not read `#result`, and moved in front of a
  Return of `#result` it fails (confirmed on 6.4.0.1164).
- On 6.4.0.1164 the editor's settings panel for this shape can fail with a 404 "Could not find
  documentation for element type Signal resume ... intercom access token". That is the help text
  the UI loads for the shape, not a compile error. On a Frends-hosted tenant, report it to Frends
  support; meanwhile the MCP route (`process_add_signal_rehydration`) configures the shape without
  the panel.

## Serialization
BPMN `intermediateCatchEvent`; JSON `Type` **26**. Confirmed `Parameters`:
```json
{ "useSignalRehydrationMode": { "mode": "toggle", "value": true },
  "correlationId":            { "mode": "csharp", "value": "#trigger.data.events.correlationId" } }
```
See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/long-running-process-shapes/signal-resume.md`
