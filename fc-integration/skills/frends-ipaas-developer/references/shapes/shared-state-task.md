# Shared State Task shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Reads and writes Frends **Shared State Storage** — a simple temporary key/value store for passing
data between Process executions (e.g. a cursor, a token, a dedupe marker). The operation is chosen
per shape.

## Fields / configuration (operation `AddOrUpdate`, confirmed)
- **keyExpression** — the key (text/Handlebars or Expression).
- **valueExpression** — the value to store (Expression).
- **ttlValue** × **ttlMultiplier** — time-to-live (e.g. `60` × `60` seconds).
- **throwIfFalse** — throw if the operation reports failure.
- **isGlobalScope** — global vs Process-scoped storage.

Other operations exist (e.g. `TryGetValue`); the operation is the shape's `SelectedTypeId`.

## Serialization
BPMN `businessRuleTask`; JSON `Type` **20**; `SelectedTypeId` = the operation (`AddOrUpdate`,
`TryGetValue`, ...). Confirmed `Parameters` for `AddOrUpdate`:
```json
{ "keyExpression":   { "mode": "text",    "value": "key" },
  "valueExpression": { "mode": "csharp",  "value": "#result" },
  "ttlValue":        { "mode": "integer", "value": 60 },
  "ttlMultiplier": 60, "throwIfFalse": true, "isGlobalScope": false }
```
`ttlMultiplier`, `throwIfFalse`, and `isGlobalScope` are plain values, not `{mode,value}` leaves.
Note Shared State (20) and [DMN](dmn-task.md) (21) both render as `businessRuleTask`. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/shared-state-task.md`,
`https://docs.frends.com/frends-development/integrations/shared-state-storage.md`
