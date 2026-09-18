# The unhandled-error Subprocess hook, serialized

**Category:** process-file-format · **Baseline:** Frends 6.2 (confirmed in an editor export)

## Purpose
Process settings offer "Select Subprocess to call on unhandled error". The setting is not a shape on
the canvas: it is one `ElementParameters` entry with **no matching BPMN element**, so a generator
that derives entries from the diagram will silently drop it.

## Serialization
`Type` **18**, with the literal id `globalErrorHandler` and `SelectedTypeId` set to the chosen
Subprocess's GUID. From `examples/scope_catch_export_6.2.json`:

```json
{
  "Id": "globalErrorHandler",
  "Type": 18,
  "Parameters": {
    "error": { "mode": "csharp", "value": "#var.error" },
    "customer": { "mode": "text", "value": "My Customer Name" },
    "__timeoutMinutes": 180,
    "topLevelProcessName": { "mode": "csharp", "value": "#process.name" },
    "topLevelProcessExecutionId": { "mode": "csharp", "value": "#process.executionid" }
  },
  "SelectedTypeId": "6e0db9eb-3548-48df-a147-c17a33240ccf",
  "Name": "GlobalErrorHandler",
  "ShouldRetry": null
}
```

The parameter keys are the chosen Subprocess's own manual trigger parameter names, the same as a
[Call Subprocess](../shapes/call-subprocess.md) shape, plus `__timeoutMinutes` as a bare number
rather than a `{mode,value}` leaf. `#process.executionid` is lower-case here, as the editor writes
it.

## Gotchas
- The hooked Subprocess GUID does **not** appear in `UsedSubprocessesJson` unless the process also
  calls it from a shape. Deployment ordering still applies: deploy the handler first.
- The hook cannot resume the failed run. It is reporting and cleanup only, and the platform provides
  **no loop protection** if the handler itself fails. See
  [../guides/error-handling.md](../guides/error-handling.md) for which processes should leave it empty.
- A [Throw](../shapes/throw.md) can opt out of it per shape with
  `"bypassGlobalExceptionHandler": { "mode": "toggle", "value": true }`.

## Related
[exception-handler-rules.md](exception-handler-rules.md) ·
[shape-type-codes.md](shape-type-codes.md) ·
[../guides/error-handling.md](../guides/error-handling.md)

## Source of truth
`examples/scope_catch_export_6.2.json`, an editor export from a Frends 6.2 tenant (6.2.3.3649).
