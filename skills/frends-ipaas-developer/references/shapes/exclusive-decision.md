# Exclusive Decision shape

**Category:** shape · **Baseline:** Frends 6.3 (serialization confirmed against a production tenant)

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

## Serialization (confirmed)
- BPMN `exclusiveGateway` carrying `default="<flowId>"`; JSON `Type` **2**.
- **The condition lives on the gateway's own `ElementParameters` entry**:
  `{"expression": {"mode": "csharp", "value": "<bool expr>"}}`.
- The labeled outgoing flows get `ElementParameters` entries of `Type` **4** with **empty**
  `Parameters` `{}`, `Name` set to the branch label (`yes`/`no`) and `IsDefault` true on the
  default flow / false on the condition flow. Unlabeled flows have no entry at all.
- No `conditionExpression` element appears in the BPMN.

See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md) and
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Gotchas
- Decision fields can't use Handlebars/Text — they're always C# expressions.
- **The import parser enforces structured flow**: each branch must terminate (its own
  Return/Throw/end event) or reconverge at the same single node, properly nested — see
  [../process-file-format/structured-flow-rules.md](../process-file-format/structured-flow-rules.md).
- Referencing `#result` of a shape that only ran on one branch after the branches rejoin fails
  compilation (CS0165) — see
  [../expressions/result-reference-scope.md](../expressions/result-reference-scope.md).

## Source of truth
`https://docs.frends.com/reference/shapes/decision-shapes/exclusive-decision.md`; serialization
confirmed against Frends 6.3 exports.
