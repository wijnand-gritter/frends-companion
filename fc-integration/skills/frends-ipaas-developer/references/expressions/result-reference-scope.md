# #result references and branch scope

**Category:** expressions · **Baseline:** Frends 6.3 (process compiler behavior)

## Purpose
Where `#result[Shape name]` may be referenced. The process compiles to C# in which each
shape's result is a local variable (`frends_returnVar_<shapeId>`); C# definite-assignment
analysis applies. Violations fail import with:

```
Failed to import: error CS0165: Use of unassigned local variable 'frends_returnVar_<shapeId>'
```

## The rule
`#result[X]` is only valid in shapes that execute on a path where X has **always**
executed:

- Same branch, after X: valid.
- After the branches of a gateway rejoin, referencing a shape that only exists on one
  branch: **compile error**, even inside a runtime-guarded ternary or if-statement. The
  compiler does not know the guard implies execution.
- Shapes on the main lane before any branching: valid everywhere downstream.

## The pattern
Promote branch-dependent values to **process variables on the branch that produces
them**, then reference only `#var.*` after the join:

- Branch A: Assign `relationId` = `#result[Create broker organisation].Body...BcCo`
- Branch B: Assign `relationId` = `#result[Create organisation].Body...BcCo`
- After the join: use `#var.relationId`.

Both branches may assign the same variable name; whichever branch ran supplies the
value. Assign shapes are cheap; one per branch-dependent value keeps every downstream
expression compilable.

## Related
[../process-file-format/structured-flow-rules.md](../process-file-format/structured-flow-rules.md)

## Source of truth
Compiler behavior observed on Frends 6.3 imports (CS0165 with the generated local
variable naming); consistent with the process-to-C# compilation model.
