# DMN Task shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Evaluates a **DMN decision table** (Decision Model and Notation) in one shape — a clean way to handle
complex business logic / decision trees without a sprawl of [Decision](exclusive-decision.md) shapes.

## Fields / configuration
- **useDmnMode** — toggle enabling DMN mode.
- **dmnXml** — the embedded DMN model XML (Camunda/OMG DMN 1.1: `definitions` → `decision` →
  `decisionTable` with `input`, `output`, and `rule` rows). Inputs feed the table; the matched
  rule's outputs become the result.

## Serialization
BPMN `businessRuleTask`; JSON `Type` **21**; `SelectedTypeId` = `Dmn`. Confirmed `Parameters` shape:
```json
{ "useDmnMode": { "mode": "toggle", "value": true },
  "dmnXml": "<definitions ... ><decision ...><decisionTable ...> ... </decisionTable></decision></definitions>" }
```
`dmnXml` is a plain string holding the DMN model. DMN (21) and [Shared State](shared-state-task.md)
(20) both render as `businessRuleTask`; the `Type`/`SelectedTypeId` distinguish them. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/dmn-task.md`,
`https://docs.frends.com/guides/development/using-dmn-task-in-frends-processes.md`
