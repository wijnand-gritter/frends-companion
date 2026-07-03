# Exclusive Decision shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Single either/or branch. One boolean C# expression: the "Yes" branch runs on `True`, the Default
branch otherwise. Use for "did the lookup succeed", "is amount over threshold", etc.

## Fields / configuration
- One condition field, **locked to C# Expression** (not Text/Handlebars), validated to resolve to
  `bool`.
- A configurable Default ("No") branch.

## Expressions and references
The condition is C# returning `bool`, e.g. `#result[Get Customer].StatusCode == 200`. See
[../expressions/reference-syntax.md](../expressions/reference-syntax.md).

## Serialization
BPMN `exclusiveGateway` (carries `default="<flowId>"`); JSON `Type` **2**. Branch conditions live on
the outgoing `sequenceFlow` entries (`Type` 4). See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Gotchas
Decision fields can't use Handlebars/Text — they're always C# expressions.

## Source of truth
`https://docs.frends.com/reference/shapes/decision-shapes/exclusive-decision.md`
