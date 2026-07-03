# Process

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
A **Process** is the main building block: a visual workflow modelled in BPMN 2.0 that describes
what should happen. It usually starts with a [Trigger](../triggers/) and continues through
[Tasks](task.md) that do the work (call an API, read a file, transform data, send data onward).

## Key facts
- Processes are created and edited **only in the Development [Environment](environment.md)**, then
  deployed elsewhere for execution.
- Every Process starts at a Trigger and ends at a [Return](../shapes/return.md) or
  [Throw](../shapes/throw.md). See [../guides/bpmn-modeling.md](../guides/bpmn-modeling.md).
- Each save creates a new **version** (see [../guides/deployment.md](../guides/deployment.md)).
- A Process compiles into a NuGet package at build; its serialized form is described in
  [../process-file-format/proprietary-json.md](../process-file-format/proprietary-json.md).

## Source of truth
`https://docs.frends.com/reference/process-development/process.md`
