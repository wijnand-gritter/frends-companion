# Assign Variable shape

**Category:** shape · **Baseline:** Frends 6.3 (serialization and runtime types confirmed against a production tenant)

## Purpose
Assign a value to a `#var` variable — or run an expression with no assignment to mutate an object in
place. The readable alternative to setting variables inside a Code Task.

## Fields / configuration
- **Default:** an Expression field; its C# value is assigned to the named `#var` variable.
- The field type can switch to **Text** so the value is built with Handlebars (useful for strings).
- **Statement mode** (`useStatementMode`): the value is a multi-line C# block ending in
  `return <value>;` — used for transforms and computed assignments.
- **No-assignment mode:** run an expression that does not resolve to a value (e.g. appending to a
  `JArray` in place). In this mode it is a validation error for the expression to return a value.

## Value modes and runtime types
The value mode determines the variable's **runtime type**, and getting it wrong fails only at
execution, on whichever path first reads the variable:

- **`json` mode holds JSON text, not a parsed object.** A variable assigned
  `{"mode": "json", "value": "{}"}` is a **string** at runtime. Indexing it with a string key
  (`#var.response["error"]`) binds to the string integer indexer and fails with
  `The best overloaded method match for 'string.this[int]' has some invalid arguments`.
- **`csharp` mode holds whatever the expression returns.** To hold a structured object, assign
  `new JObject()` (csharp mode), not `{}` (json mode).
- **`text` + Handlebars renders to a string**, including when the rendered text looks like JSON.

The failure surfaces path-dependently: branches that overwrite the variable with a JObject before
reading it work; the one branch that leaves the initial value in place (e.g. a 204 happy path that
never builds a response body) hits the binder error at the first `#var.x["key"]` read. **Rule:**
initialize envelope/accumulator variables with csharp `new JObject()` so every path reads the same
type; reserve json mode for values consumed as text.

## Expressions and references
Read with `#var.Name` elsewhere. See
[../expressions/reference-syntax.md](../expressions/reference-syntax.md) and
[../expressions/field-types.md](../expressions/field-types.md). For which shapes may read a
variable assigned inside a branch, see
[../expressions/result-reference-scope.md](../expressions/result-reference-scope.md) — `#var`
survives joins, `#result` does not.

## Serialization (confirmed)
BPMN `scriptTask`, JSON `Type` **12** — the same code as a Code Task; an Assign is distinguished by
its `Parameters`:

```json
{
  "variableName": "response",
  "variableExpression": {"mode": "csharp", "value": "new JObject()"},
  "shouldAssignVariable": {"mode": "toggle", "value": true},
  "useStatementMode": {"mode": "toggle", "value": true}   // only for statement-mode blocks
}
```

See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md) and
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Gotchas
- Prefer this shape over `#var` assignments buried in Code Tasks, so each step is inspectable in the
  Process Instance view.
- The json-mode string trap above.

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/assign-variable.md`; serialization and
runtime types confirmed against Frends 6.3 exports and executions.
