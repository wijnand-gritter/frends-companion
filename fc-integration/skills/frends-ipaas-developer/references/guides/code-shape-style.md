# Guide: C# style in Code shapes

**Category:** guide · House rules for the C# inside Code/Assign shapes. Many developers reading
these flows are new to C#; the code must read without archaeology.

## Naming: full words, no abbreviations

Name variables for what they hold, fully. Never single letters, never abbreviations:

| Bad | Good |
| --- | --- |
| `var c = (JObject)#var.counters;` | `var counters = (JObject)#var.counters;` |
| `var ra = ...` | `var retryAfterSeconds = ...` |
| `var res = #result[HS search];` | `var response = #result[HS search];` |
| `var sr = body["salesRelation"]` | `var salesRelation = body["salesRelation"]` |
| `foreach (var r0 in rows) { var r = (JObject)r0; }` | `foreach (var rowToken in rows) { var row = (JObject)rowToken; }` |
| `JToken Val(JToken t)` | `JToken ValueOrNull(JToken token)` |

- The only exception: `i`/`j` as plain `for`-loop counters.
- The token/cast pair pattern for JArray iteration: `xToken` for the loose `JToken`, `x` for the
  cast (`recordToken`/`record`, `rowToken`/`row`).
- Local helper functions get verb-noun names (`ValueOrNull`, `ToDateString`, `MapStage`), and
  their parameters follow the same rules (`token`, `defaultValue` - not `t`, `d`).

## Frends variable names follow the same rule

`#var` names surface in expressions all over the process, so abbreviations spread. Use
`readControl`, `updateControl`, `propertyPlan` - not `readCtrl`, `updCtrl`, `propPlan`. Renaming
one later means touching every Assign `variableName`, gateway expression, loop condition and
code reference that mentions it, so get it right at generation time.

## Comments: sparse, why-not-what

Do not comment every line - full-word naming carries the what. Comment only the *why* that the
code cannot say:

```csharp
// last write wins per HubSpot id (batch update rejects duplicate ids)
var byHubSpotId = new Dictionary<string, JObject>();
```

A `TODO` with a concrete open question is fine; a comment restating the next line is noise.

## Formatting

- One statement per line; no compressed `if (x) { a; b; }` one-liners beyond a single guard.
- Align object-initializer values only when it genuinely aids scanning (JObject field maps).
- Keep the shape's code focused: if a Code shape needs more than one screen, consider whether a
  helper function inside the shape, or a separate shape, tells the story better.

## Why this matters here specifically

Frends compiles all shapes into one class; a `CS0136`/`CS0165` from a name collision or an
unassigned branch variable surfaces at **import**, with the shape name in the error. Consistent,
distinct, full-word names both prevent those collisions and make the import errors instantly
traceable. See
[../expressions/result-reference-scope.md](../expressions/result-reference-scope.md).
