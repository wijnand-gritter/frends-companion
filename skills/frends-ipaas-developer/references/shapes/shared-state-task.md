# Shared State Task shape

**Category:** shape · **Baseline:** Frends 6.3 (all operations confirmed against a production-tenant export)

## Purpose
Reads and writes Frends **Shared State Storage** - a TTL-bound key/value store for passing data
between Process executions (a cursor/watermark, a token, a dedupe marker). The operation is chosen
per shape.

## Operations (all 8)
`AddOrUpdate`, `GetOrAdd` (get, or create with the given value - a one-shape
read-with-default), `TryAdd`, `TryGetValue`, `TryRemove`, `TryUpdate`, `GetTTL`, `UpdateTTL`.

## Result (all operations)
- `#result.Success` (bool) - whether the operation succeeded
- `#result.Value` (dynamic) - the value retrieved from or inserted into storage
- `#result.Message` (string) - textual information about the execution

Read-with-default pattern: `TryGetValue` (with `throwIfFalse: false`) then
`#result[Get X].Success ? (string)#result[Get X].Value : "<default>"` - or a single `GetOrAdd`
when writing the default back on first use is acceptable.

**`.Value` is not type-stable across the round trip.** Stored values pass through Json.NET on
read, whose default `DateParseHandling` turns anything ISO-datetime-shaped
(`2026-09-01T00:00:00`) into a `System.DateTime` - even when you stored it as a string. A blind
`(string)#result[Get X].Value` then fails at runtime with
`RuntimeBinderException: Cannot convert type 'System.DateTime' to 'string'`, and only from the
**second** run onward (the first run takes the not-found default, so tests miss it). For any
value that can look like a date - watermarks above all - read it tolerantly:

```csharp
!#result[Get X].Success ? "<default>"
  : (#result[Get X].Value is DateTime
      ? ((DateTime)#result[Get X].Value).ToString("yyyy-MM-dd'T'HH:mm:ss")
      : (string)#result[Get X].Value)
```

The same Json.NET conversion applies to Manual Trigger parameter values - see
[../triggers/manual.md](../triggers/manual.md).

## Serialization (confirmed)
BPMN `businessRuleTask`; JSON `Type` **20**; `SelectedTypeId` = the operation name.
**Every operation carries the identical full parameter set** - omitting fields fails import,
including for operations that ignore them (read-only ops carry `valueExpression` as csharp `""`):

```json
{ "keyExpression":   { "mode": "text",    "value": "my_key" },
  "valueExpression": { "mode": "text",    "value": "my_value" },
  "ttlValue":        { "mode": "integer", "value": "1" },
  "ttlMultiplier": 3600, "throwIfFalse": true, "isGlobalScope": false }
```

- `ttlMultiplier`, `throwIfFalse`, `isGlobalScope` are plain values, not `{mode,value}` leaves.
- `ttlMultiplier` is the TTL unit in seconds (observed: 60 = minutes, 3600 = hours);
  TTL = `ttlValue x ttlMultiplier`.
- `isGlobalScope: true` = available to all Processes in the Agent Group.
- `PromoteResultAs` works on this shape; the promoted name must also be listed in the process's
  `PromotedResultVariablesJson`.

Note Shared State (20) and [DMN](dmn-task.md) (21) both render as `businessRuleTask`. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/shared-state-task.md`,
`https://docs.frends.com/frends-development/integrations/shared-state-storage.md`;
serialization confirmed against a Frends 6.3 export containing all eight operations.
