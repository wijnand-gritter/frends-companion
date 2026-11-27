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

## Block helpers (6.4)
From 6.4.0, Text fields also take conditions and loops (docs):

```handlebars
{{#if #var.order.IsPaid}}Paid{{else if #var.order.IsDue}}Due{{else}}Open{{/if}}
{{#each #var.order.Lines}}{{@index}}: {{this}}
{{/each}}
```

`{{this}}` is the current item and `{{@index}}` its position. An existing Process picks this up
after it is rebuilt (saved as a new version). Keep block helpers to presentation, such as a message
body or a file line. A condition that decides what the Process does belongs in a
[Decision](../shapes/exclusive-decision.md) ([../guides/native-shapes-first.md](../guides/native-shapes-first.md)).

The 6.4 expression editor checks syntax as you type and completes Process Variables and shape
results.

## Related
[field-types.md](field-types.md) · [reference-syntax.md](reference-syntax.md). Note the trigger-field
exception in [../triggers/parameter-fields.md](../triggers/parameter-fields.md), where `#env` works
without Handlebars and other Handlebars are left literal.
