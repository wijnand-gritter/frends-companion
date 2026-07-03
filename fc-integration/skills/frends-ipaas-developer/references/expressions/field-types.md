# Field types: Expression vs Text

**Baseline:** Frends 6.2 · part of the C# expressions layer

The single most consequential field setting. Most Task and shape input fields can be switched
between two types, and the same content behaves differently depending on which.

- **Expression** — the field contains a single C# expression that resolves to a value at run time.
  The resolved value's type must match what the field expects (Text/number fields want
  String/Integer; selector fields a specific enum or class). An "expression" is a literal,
  calculation, method call, field access, object creation, or lambda. An **assignment is not an
  expression** (it doesn't resolve to a value).
- **Text** — plain text. C# can be embedded via Handlebars `{{ }}`. Text, JSON, XML, and SQL fields
  are all "text type" and accept Handlebars. See [handlebars.md](handlebars.md).

**Common mistake:** writing `#result[X].Body` in a Text field without Handlebars — it is treated as
literal text and not evaluated. Either switch the field to Expression, or wrap it:
`{{#result[X].Body}}`.

## Serialization
In an export, the field type is the `mode` of each `{mode,value}` leaf: `csharp` = Expression,
`text`/`json`/`sql`/`xml` = text-type, plus `select`, `toggle`, `integer`. See
[../process-file-format/parameter-encoding.md](../process-file-format/parameter-encoding.md).

## Related
[reference-syntax.md](reference-syntax.md) · [../triggers/parameter-fields.md](../triggers/parameter-fields.md)
(trigger fields are a special case).
