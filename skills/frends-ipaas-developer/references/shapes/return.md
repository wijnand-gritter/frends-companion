# Return shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Normal end of a Process path, optionally returning a value. For an API Process it returns the HTTP
response.

## Fields / configuration
- A general Return carries an `expression` leaf (the value to return).
- An HTTP API Return (`SelectedTypeId: "HttpResult"`) carries `httpStatusCode` (integer),
  `httpContentType` (text), `httpContent` (json), `httpContentEncoding` (text), and `httpHeaders`.

## Expressions and references
To return a Task's output, set the field to **Expression** and reference it, e.g.
`#result[HTTP Request].Body`. If left as Text the reference is not evaluated (or wrap it in
Handlebars). See [../expressions/field-types.md](../expressions/field-types.md).

## Serialization
BPMN `endEvent`; JSON `Type` **5**; `SelectedTypeId` is `Expression` or `HttpResult`. See
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Source of truth
`https://docs.frends.com/reference/shapes/event-shapes/return.md`
