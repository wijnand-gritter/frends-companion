# Intermediate Return shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Returns a response to the caller **and continues processing asynchronously**. The key use is before a
[Checkpoint](checkpoint.md) on an HTTP/API-triggered Process, so the caller gets an immediate response
instead of timing out while the Process pauses or does long work.

## Fields / configuration
- **expression** — the value/response to return at this point. Like a [Return](return.md), set it to
  Expression to evaluate a reference, or Text (with Handlebars) for a literal/string.

## Serialization
BPMN `endEvent`; JSON `Type` **17**. Confirmed `Parameters`:
```json
{ "expression": { "mode": "text", "value": "\"An exception has occurred\"" } }
```
Distinguished from a normal [Return](return.md) (`Type` 5) by the code. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/event-shapes/intermediate-return.md`
