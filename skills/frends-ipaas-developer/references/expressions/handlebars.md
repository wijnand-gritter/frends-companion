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

## Related
[field-types.md](field-types.md) · [reference-syntax.md](reference-syntax.md). Note the trigger-field
exception in [../triggers/parameter-fields.md](../triggers/parameter-fields.md), where `#env` works
without Handlebars and other Handlebars are left literal.
