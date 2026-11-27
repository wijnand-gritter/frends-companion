# Code Task shape

**Category:** shape · **Baseline:** Frends 6.2, 6.3 changes noted

## Purpose
A scope for multi-line C# — the "code" in low-code. Use it for one logical action that needs more
than a single Expression and that no Task or native shape can do. It is the last option in
[../guides/native-shapes-first.md](../guides/native-shapes-first.md): no calls to outside systems,
no route decisions, no business `throw`, no hard-coded value lists.

## Fields / configuration
- A C# code block (`variableExpression`, `csharp` mode). Optional `useStatementMode` toggle.
- `shouldAssignVariable` toggle + `variableName` (a plain string): when on, the code's `return`
  value is assigned to `#var.<variableName>`.

## Expressions and references
Full Frends C# applies, but with the editor's **namespace limits** — see
[../expressions/code-tasks.md](../expressions/code-tasks.md) and
[../expressions/namespaces.md](../expressions/namespaces.md). Keep to **one logical action per Code
Task**; push branching/assignment into [decision](exclusive-decision.md) and
[assign-variable](assign-variable.md) shapes so the Process Instance view stays legible.

## Serialization
BPMN `scriptTask`; JSON `Type` **12**. `variableName` is a plain string, not a `{mode,value}` leaf.
See [../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Gotchas
- **Cannot add new `using`/libraries.** `using` is allowed only for resource disposal. If you need a
  library Frends doesn't load, write a [custom Task](../tasks/authoring.md) instead.
- With assignment disabled, do not return a value (behave like `void`). A `return` with a value
  then fails with CS8030 (validated on 6.3.2.5468).
- 6.3: the shape can `await` directly; .NET 10 APIs and C# 14 are available
  ([../expressions/csharp-versions.md](../expressions/csharp-versions.md)).
- 6.3: Code shape names must be unique in the Process; the editor rejects duplicates.
- 6.3: `#process.SendTcpMessage` is no longer offered by completion in the Statement Code shape.
- Before 6.4.0, a Code shape whose code ended in a `//` line comment failed to compile. Fixed in 6.4.0.
- 6.4: JSON mapping belongs in a [Visual Data Mapper](visual-data-mapper.md), not in a Code shape.

## Example
```csharp
{ var headers = new List<Frends.HTTP.Request.Definitions.Header>();
  headers.Add(new Frends.HTTP.Request.Definitions.Header { Name="Content-type", Value="application/json" });
  return headers.ToArray(); }
```

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/code-task.md`
