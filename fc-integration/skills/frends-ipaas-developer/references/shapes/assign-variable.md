# Assign Variable shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Assign a value to a `#var` variable — or run an expression with no assignment to mutate an object in
place. The readable alternative to setting variables inside a Code Task.

## Fields / configuration
- **Default:** an Expression field; its C# value is assigned to the named `#var` variable.
- The field type can switch to **Text** so the value is built with Handlebars (useful for strings).
- **No-assignment mode:** run an expression that does not resolve to a value (e.g. appending to a
  `JArray` in place). In this mode it is a validation error for the expression to return a value.

## Expressions and references
Read with `#var.Name` elsewhere. See
[../expressions/reference-syntax.md](../expressions/reference-syntax.md) and
[../expressions/field-types.md](../expressions/field-types.md).

## Serialization
JSON `Type` **8** is *likely* an Assign Variable (seen on a no-parameter activity in the
full-Process export; identity unconfirmed). Confirm from an export that configures one. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Gotchas
Prefer this shape over `#var` assignments buried in Code Tasks, so each step is inspectable in the
Process Instance view.

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/assign-variable.md`
