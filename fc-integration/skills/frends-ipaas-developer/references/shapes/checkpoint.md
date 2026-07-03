# Checkpoint shape

**Category:** shape (long-running) · **Baseline:** Frends 6.2

## Purpose
Stores the state of the Process into the Agent database and optionally **pauses (dehydrates)** it
until resumed later. Also useful purely as a backup/retry point: even when set to continue
immediately, the state is saved so the path can be retried after an error.

## Fields / configuration
- **Correlation ID** — string key the dehydrated state is stored under; [Signal Resume](signal-resume.md)
  uses the same value to resume this Checkpoint from another Process.
- **Time to Live** — minutes the state is kept (max Int32). If exceeded while paused, the context is
  discarded and the Process is reported failed.
- **Continue Execution** — toggle: dehydrate/pause here, or store state and continue immediately.

## Expressions and references
Exposes `#result` after resume: `.HydrationPoint`, `.CorrelationId`, `.TriggerId`, `.Variables`
(JObject of stored values actually used after the Checkpoint), `.OriginalProcessStartTimeUtc`,
`.Iteration`. With HTTP/API triggers, put an [Intermediate Return](intermediate-return.md) **before**
the Checkpoint so the caller gets a response instead of timing out. State size is capped by the Agent
setting `MaxDehydratedProcessDataSizeKb` (default 1024).

## Serialization
BPMN `intermediateCatchEvent`; JSON `Type` **24**. Confirmed `Parameters`:
```json
{ "correlationId":     { "mode": "csharp",  "value": "#process.executionid" },
  "ttlMinutes":        { "mode": "integer", "value": 1440 },
  "continueExecution": { "mode": "toggle",  "value": false } }
```
See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/long-running-process-shapes/checkpoint.md`
