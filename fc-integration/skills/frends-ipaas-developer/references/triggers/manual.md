# Manual Trigger

**Category:** trigger · **Baseline:** Frends 6.3 (parameter encoding confirmed against a production-tenant export)

## Purpose
On-demand "Run once" from the UI (or as the entry for monitoring rules), with optional prompted
parameters - the standard way to give OPS a hand-run with inputs (an entity to replay, a date to
resync from).

## Parameters
Each parameter has a name, default value and description; values arrive under
`#trigger.data.<name>`. `isSecret: true` masks the value in the run dialog.

**Values are not always strings.** Trigger data passes through Json.NET, whose default
`DateParseHandling` converts anything that looks like an ISO date/time (`2026-09-01T00:00:00`)
into a `System.DateTime`. A blind cast then fails at runtime with
`RuntimeBinderException: Cannot convert type 'System.DateTime' to 'string'`. Never write
`(string)#trigger.data.x` for a parameter that can hold a date; use the tolerant pattern:

```csharp
// null/empty check that works for both string and DateTime:
!string.IsNullOrWhiteSpace(Convert.ToString(#trigger.data.fromDate))

// reading it back in a known format:
#trigger.data.fromDate is DateTime
  ? ((DateTime)#trigger.data.fromDate).ToString("yyyy-MM-dd'T'HH:mm:ss")
  : (string)#trigger.data.fromDate
```

Plain-text parameters (an entity name, a source key) stay strings and can be cast directly.

## Serialization (confirmed)
Three coordinated pieces:

1. **`ManualTriggerJson`** (process-level) holds the parameter definitions:
```json
[{ "type": "System.String", "inputType": "text", "parameterType": "TextParameter",
   "defaultValue": "x", "displayOption": "", "conditionalDisplayProperty": "",
   "conditionalDisplayValues": [], "isInvalid": false, "invalidString": "",
   "name": "source", "isSecret": false,
   "nonStringifiedDefaultValue": "x", "description": "..." }]
```
2. **Trigger `config`** (in `TriggersJson`) and the trigger's **`ElementParameters` entry** both
   carry the defaults keyed **by position**: `{"manualTriggerDefaultValue-0": "x",
   "manualTriggerDefaultValue-1": "y"}` - keep all three in sync.
3. JSON `Type` 0, `SelectedTypeId: "ManualTrigger"`, `$type: "ManualTrigger"`.

## Routing pattern
A process with schedule triggers plus a Manual trigger routes per firing with decisions on
`#trigger.name` and the manual parameters, short-circuited so schedule runs never touch
`#trigger.data`:

```csharp
#trigger.name == "Schedule - free tables"
  || (#trigger.name == "Manual" && (string)#trigger.data.source == "freeTables")
```

## Source of truth
`https://docs.frends.com/reference/triggers/manual-trigger.md`; encoding confirmed against a
Frends 6.3 export with configured parameters (incl. a secret parameter).
