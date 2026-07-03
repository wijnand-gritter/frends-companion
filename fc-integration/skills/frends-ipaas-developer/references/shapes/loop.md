# Loop shapes (Foreach / While)

**Category:** shape · **Baseline:** Frends 6.2

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

## Serialization
A loop is an embedded `subProcess` in BPMN, with a nested scope start (`Type` 13). Confirmed 6.2 Type
codes: **Foreach = `Type` 10**, **While = `Type` 11** (a plain [Scope](scope-and-catch.md) is `Type`
8). The `ElementType` enum names them `SequentialForeach`, `ParallelForeach`, `While`. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md) and
[scope-and-catch.md](scope-and-catch.md).

## Source of truth
`https://docs.frends.com/reference/shapes/scope-shapes/foreach.md`,
`https://docs.frends.com/reference/shapes/scope-shapes/while.md`
