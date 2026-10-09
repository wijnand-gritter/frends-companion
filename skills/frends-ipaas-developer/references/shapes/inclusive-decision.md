# Inclusive Decision shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Multiple branches that can run together. Each branch has its own boolean expression; **every branch
whose expression is `True` executes**. An optional default runs if none did.

## Fields / configuration
- One boolean C# expression per branch, **locked to C# Expression**, each validated to resolve to
  `bool`.
- Optional default branch.

## Expressions and references
C# booleans per branch. See [../expressions/reference-syntax.md](../expressions/reference-syntax.md).

## Serialization
BPMN `inclusiveGateway`; JSON `Type` for the inclusive gateway is **not present in the bundled
samples** — confirm against a real export before generating one. Branch conditions live on the
outgoing `sequenceFlow` entries (`Type` 4). See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Gotchas
Unlike Exclusive, more than one branch can fire — design downstream merges accordingly.

From 6.3.1 the shape has "Skip logging result and parameters", like Task shapes; set it when a
branch condition reads sensitive data. Branch names cannot contain a double quote.

**Not parallel.** The branches that fire run one after another, in creation order. Do not use an
Inclusive Decision to speed a Process up (Frends process optimisation guide).

## Source of truth
`https://docs.frends.com/reference/shapes/decision-shapes/inclusive-decision.md`
