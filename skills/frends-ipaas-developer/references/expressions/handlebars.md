# Handlebars in Text fields

**Baseline:** Frends 6.2

In a Text-type field, `{{ ... }}` embeds a C# expression whose value is spliced into the string at
run time.

- Handlebars apply an implicit `ToString()`. The expression is validated as if interpolated:
  `$"{#var.Variable.ToString()}"`.
- Cleaner than a full Expression when assembling a string from several values, or when a long
  literal has a few embedded values.
- Because of the implicit `ToString()`, developers often use Handlebars to drop a single value into
  a field rather than switching the field to Expression.

## Conditions and loops (6.4)
From 6.4.0, text-mode parameters take conditions and loops. They work in every text-type field:
Text, JSON, XML and SQL. That covers Task parameters, Assign Variable and Code shapes in a text
mode, Return and Throw shapes, and Visual Data Mapper mappings. Expression fields do not use them,
and trigger parameters do not evaluate them (docs).

```handlebars
{{#if #var.Status == "active"}}Active
{{else if #var.Status == "pending"}}Pending
{{else}}Unknown{{/if}}
```

- The condition is any C# expression that resolves to a `bool`, with `#var`, `#result`, `#env` and
  the other references. Conditions are evaluated in order, and a later one only when the earlier
  ones were false.
- `{{else if}}` is optional and may repeat. `{{else}}` is optional, appears at most once and comes
  after every `{{else if}}`. `{{/if}}` is required.

```handlebars
[{{#each #var.Orders}}{"id": {{JsonConvert.ToString(this.OrderId)}}}{{#if @index < #var.Orders.Count - 1}},{{/if}}{{/each}}]
```

- The collection is any reference that resolves to an array, list or other enumerable.
- `{{this}}` is the current item, `{{this.OrderId}}` one of its properties, and `{{@index}}` its
  zero-based position. `@first`, `@last`, `@key`, `../` and helpers such as `{{#unless}}` and
  `{{#with}}` are not documented; do not rely on them. Use `@index` for separators, as above.
- Conditions and loops can be nested in each other.
- Directives are case-insensitive, and whitespace around a directive does not matter. Whitespace
  inside a block body is kept in the output, so a template laid out across lines for readability
  also puts those line breaks in the result. For a JSON body that is harmless; for a CSV line or a
  fixed-width file, write the block on one line.
- An existing Process picks this up only after it is rebuilt (saved as a new version).

### Escaping
Values are inserted as raw text; nothing is escaped for you (docs).
- JSON: `"name": {{JsonConvert.ToString(#var.CustomerName)}}`, without quotes around the
  Handlebars. `JsonConvert.ToString` adds the quotes and escapes the content, so a name with a
  quote or a line break still gives valid JSON.
- XML: `<Name>{{System.Security.SecurityElement.Escape(#var.CustomerName)}}</Name>`.
- SQL: use the Task's query parameters, not Handlebars, for values. Inserting a value into SQL text
  invites injection.

### When to use them
Keep conditions and loops to presentation: a message body, an e-mail, a file line, an optional
element in a request. A condition that decides what the Process does belongs in a
[Decision](../shapes/exclusive-decision.md), which takes a plain Expression field only, and a
mapping from one JSON structure to another belongs in a
[Visual Data Mapper](../shapes/visual-data-mapper.md)
([../guides/native-shapes-first.md](../guides/native-shapes-first.md)). A `{{#each}}` that builds
a JSON array by hand is fine for a small payload; for a full mapping, the mapper shows each field on
the canvas.

### Errors
The editor checks syntax as you type and points at the error. Structural errors (a missing
`{{/if}}`, `{{else}}` before `{{else if}}`, a second `{{else}}`) stop the save. Errors that depend on
the data, such as a null collection or a missing property, appear only when the Process runs, so
guard optional data with a condition: `{{#if #var.Orders != null}}...{{/if}}`.

### Not the Handlebars Task
The JSON Task called Handlebars (`Frends.JSON.Handlebars`, from Frends 5.7) is something else: it
renders a JToken into a Handlebars template, supports partials such as `{{> partial}}`, and needs its
template in Expression mode, where `{{ }}` in another mode breaks the Task. The syntax above is the
platform's own and needs no Task.

The 6.4 expression editor also completes Process Variables and shape results from their schemas.

Source: `https://docs.frends.com/reference/process-development/handlebars.md` and the 6.4.0
release notes. Docs only; not yet run on a tenant.

## Related
[field-types.md](field-types.md) · [reference-syntax.md](reference-syntax.md). Note the trigger-field
exception in [../triggers/parameter-fields.md](../triggers/parameter-fields.md), where `#env` works
without Handlebars and other Handlebars are left literal.
