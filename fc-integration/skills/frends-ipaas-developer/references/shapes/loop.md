# Loop shapes (Foreach / While)

**Category:** shape · **Baseline:** Frends 6.3 (serialization confirmed against a production tenant export)

## Purpose
Iterate over a collection (Foreach — sequential or parallel) or while a condition holds (While).
Loops are **scope shapes**: they contain a body of shapes.

## Fields / configuration
- **Foreach:** the collection to iterate and the per-item variable. Frends distinguishes
  `SequentialForeach` and `ParallelForeach`.
- **While:** a boolean C# condition evaluated each iteration.

## Expressions and references
The collection/condition are C# expressions. Keep the body small and push per-item logic into
clearly named shapes so each iteration is legible. For large collections, mind logging volume (see
[../guides/debugging.md](../guides/debugging.md)) and build result collections incrementally (an
[Assign Variable](assign-variable.md) in no-assignment mode can append to a `JArray` in place).

## Serialization (confirmed)
A loop is an embedded `subProcess` in BPMN with a nested scope start (`Type` 13) and one or more
inner Returns (`Type` 5). The loop marker is a child element of the `subProcess`:

- **While** (`Type` **11**): `<bpmn2:standardLoopCharacteristics />`; `Parameters`:
  `{"maxIterations": {"mode": "integer", "value": "1000"}, "expression": {"mode": "csharp", "value": "<bool>"}}`
- **Foreach** (`Type` **10**, sequential): `<bpmn2:multiInstanceLoopCharacteristics isSequential="true" />`;
  `Parameters`: `{"variable": "i", "expression": {"mode": "csharp", "value": "<enumerable>"}}` -
  note `variable` is a **plain string**, not a `{mode,value}` leaf. The item is read as `#var.<variable>`
  inside the body.

A plain [Scope](scope-and-catch.md) is `Type` 8. The `ElementType` enum names loops
`SequentialForeach`, `ParallelForeach`, `While`.

**`standardLoopCharacteristics` means two things**: on a `task` element it is the retry marker
(with `ShouldRetry`/`MaxRetryCount` on the entry); on a `subProcess` it makes the scope a While
loop. Do not conflate them when parsing or generating.

**While is pre-tested**, so its condition must not reference `#result` of shapes inside its own
body (definite assignment, see
[../expressions/result-reference-scope.md](../expressions/result-reference-scope.md)). Drive the
condition from a `#var` control object initialized before the loop and updated by an Assign inside
the body - this also gives a natural retry-until-accepted pattern (sentinel status + attempt
counter). See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/scope-shapes/foreach.md`,
`https://docs.frends.com/reference/shapes/scope-shapes/while.md`
