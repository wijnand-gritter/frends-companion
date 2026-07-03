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

## Serialization
BPMN `intermediateCatchEvent`; JSON `Type` **26**. Confirmed `Parameters`:
```json
{ "useSignalRehydrationMode": { "mode": "toggle", "value": true },
  "correlationId":            { "mode": "csharp", "value": "#trigger.data.events.correlationId" } }
```
See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/long-running-process-shapes/signal-resume.md`
