# Parameter encoding: the {mode, value} model

Inside an entry's `Parameters`, every editable leaf is an object `{ "mode": "...", "value": ... }`.
The `mode` is the field type — exactly the Expression-versus-Text distinction the platform exposes
in the editor (see [../expressions/field-types.md](../expressions/field-types.md)). Modes observed,
with rough frequency across templates:

- `text` (plain text, accepts Handlebars) — most common
- `csharp` (an Expression, i.e. C# that resolves to a value) — very common
- `toggle` (boolean)
- `select` (a dropdown / enum choice)
- `integer` (number)
- `json`, `sql`, `xml` (text-type editors with that syntax, accept Handlebars)

A `select` value must be the **exact enum member name from the Task's source**, not a guess and not
the field's XML-doc `<example>` (often stale). Wrong values fail import with the .NET error "Sequence
contains no matching element". Read members from the Task source on GitHub. For example
`Frends.HTTP.Request` `input.Method` is `GET`/`POST`/... (uppercase) and `input.ResultMethod` (type
`ReturnFormat`) is `String` or `JToken` (its `<example>` misleadingly says "REST"). When unsure, omit
the optional field and let the default apply, as the real template exports do.

Example leaves from real Processes:
```json
"expression": { "mode": "csharp", "value": "#result" }
"Directory":  { "mode": "text",   "value": "" }
"Port":       { "mode": "integer","value": 21 }
"ThrowErrorOnFail": { "mode": "toggle", "value": true }
```
A [Task](../shapes/task.md)'s `Parameters` mirrors the Task's parameter classes (e.g. an FTP Task
exposes `source`, `destination`, `connection`, `options`, `info`, `cancellationToken`), each a nested
object of `{mode,value}` leaves. The exact field names per Task come from that Task's source
(FrendsPlatform GitHub) or its editor tooltips. See
[../tasks/authoring.md](../tasks/authoring.md) and
[confirmed-shape-parameters.md](confirmed-shape-parameters.md).
