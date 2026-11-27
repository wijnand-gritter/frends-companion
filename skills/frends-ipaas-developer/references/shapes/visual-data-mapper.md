# Visual Data Mapper shape

Category: shape · Baseline: Frends 6.4.0 (serialisation confirmed from an MCP draft on 6.4.0.1164)

## Purpose
Maps one source onto a target object described by a JSON Schema, field by field, without C#. The
source is a shape's result, a Process Variable or the current item of an enclosing Foreach. The
result is a `JToken` that downstream shapes read as `#result[<shape name>]`. New in 6.4; a 6.3 or
6.2 tenant has no such shape.

This is the native shape for payload mapping. Where a Code shape used to build a target JSON object
field by field, the mapper now shows each mapping on the canvas and in the Process Instance
([../guides/native-shapes-first.md](../guides/native-shapes-first.md)). JSON only: the docs name
no XML or CSV mapping (docs).

## Fields / configuration
Editor labels (docs):
- Display name.
- "Strict schema validation": off by default. When on, the run throws if the result does not
  match the target schema. Confirmed on 6.4.0.1164: a required target field left unmapped ends the
  run in state Exception with `Schema validation failed: Required properties are missing from
  object: ownerId. Path ''.` Catch it like any other failure, or let the unhandled-error hook take
  it. With the toggle off, the same mapping returns an object without `ownerId`.
- Source, and a summary of the mapping rules.
- "Configure data mappings" opens the mapping editor: a source panel, a target panel with "Edit
  schema" and "Generate mapping with Frends assistant", and the "Draw lines" and "Show data tokens"
  toggles. Token colours: purple for a direct mapping, blue for a custom expression, green for a
  static value.
- "Skip logging result and parameters" and "Promote result as".

## Schemas
Both sides need a JSON Schema.
- The target schema is set on the mapper itself. Its root must be an object with properties.
- The source schema is set on the source: on a Task, Code, Assign Variable, Call Subprocess or DMN
  Task shape, or on a Process Variable in the Variables tab ("Add Schema", "Import schema" from
  sample JSON or a JSON Schema file, or "Generate a schema" from a unit-test result). AI Connector
  and Shared State results have no schema: pass them through a Code or Assign shape first (docs).
- A source schema's root may be an object or an array. Add a `description` to fields whose names
  are ambiguous; the mapping assistant reads them.
- A Process without a source schema does not validate (`MISSING_SCHEMA` on the MCP route) and cannot
  be promoted (confirmed (MCP schema)).

## One schema, one place
A schema cannot be referenced. The target schema is a literal JSON string inside the shape, with no
expression mode: the MCP builder rejects `#var.targetSchema` with "Schema is not valid JSON"
(confirmed on 6.4.0.1164), and there is no `#env` or `#var` option in the encoding. Ways to keep a
model in one place anyway:

- Within a Process, chain from the mapper. A mapper's result carries its target schema, so a second
  mapper or a later shape can use the first mapper as its source without a schema of its own.
- Across Processes, put the mapping in a Subprocess, such as `Shared - Map AFAS order to HubSpot
  deal`, and call it. The schema and the mappings then exist once, and a change is one deployment.
- To validate a payload against a schema that lives outside the Process, use a JSON Schema
  validation Task with the schema in an Environment Variable or a file. That validates; it does not
  map.

## Expressions and references
Mappings are keyed by dotted target path, without array indexes (`status.isActive`,
`lineItems.sku`). The source is `#source`, read by path (`#source.lines.quantity`).

| Target type | Mode | Value |
| --- | --- | --- |
| string | `text` | literal text with `{{#source.path}}` references, e.g. `Order {{#source.order_id}}` |
| boolean, integer, number, object, array | `csharp` | a C# expression, normally a bare `#source.path` |
| string, empty | `csharp` | the C# literal `""` |

- Map each target array with one strategy: either the whole array in one `csharp` mapping, or its
  item fields through dotted paths (`lineItems.sku` from `#source.lines.product_id`, which reads the
  current item). Never both on the same array; a mix fails validation.
- A target object either maps whole, when its structure matches the source exactly, or field by
  field. Not both.
- Map only compatible types (`integer` onto `number` is fine). Leave a target field unmapped when
  nothing in the source fits; do not invent placeholder values.
- `#source.items[0].x` reads the first item on every iteration. Paths follow the schema, never
  indexes.
- Keep a mapping to a source reference or text around one. Write other C# (a function call, an
  operator) only for a transformation the design asks for. Real logic belongs in a shape before the
  mapper.

## Serialization (confirmed, 6.4.0.1164)
BPMN `businessRuleTask`; JSON `Type` 28; `SelectedTypeId` `null`. Shared State (20) and DMN (21)
are `businessRuleTask` too; the `Type` tells them apart.

```json
{ "useVdmMode": { "mode": "toggle", "value": true },
  "sourceNodeId": "buildOrder",
  "schema": "{\"type\":\"object\",\"properties\":{...}}",
  "schemaTree": "{\"schema\":\"...\",\"tree\":[{\"key\":\"dealId\",\"type\":\"string\"}, ...]}",
  "vdmMappings": "{\"dealId\":{\"mode\":\"text\",\"value\":\"{{#source.order_id}}\"}, ...}",
  "validateResultSchema": false }
```

- `sourceNodeId` is a plain string: the source shape's id, a Process Variable name or a Foreach id.
- `schema`, `schemaTree` and `vdmMappings` are JSON documents stored as strings. `schemaTree` is
  derived from `schema` (keys, types, `arrayDepth`, `children`).
- `validateResultSchema` is a plain boolean, the "Strict schema validation" toggle.
- Source schemas live in one extra `ElementParameters` entry with `Id` `$schemas` and `Type` 22,
  which has no BPMN element. Its `Parameters` map a key to a schema string. For a Code or Assign
  Variable shape that assigns a variable, the key is the variable name (`sampleOrder`), not the
  shape id. A schema set on a Task in the editor sits in that Task's own `Parameters` as `schema`
  instead.
- Mappings saved by the editor also carry `sourceType` and `targetType` per mapping, and the shape
  carries `vdmMappingsHistory`. The MCP tools write `mode` and `value` only; both forms compile.

Full draft: [../process-file-format/examples/vdm_mcp_draft_6.4.json](../process-file-format/examples/vdm_mcp_draft_6.4.json).
The file route generator does not emit this shape; build it on the MCP route or in the editor.

## On the MCP route
1. Read `get_guide('data-mapper')`.
2. Add the source shape, then `process_set_source_schema` with the same id the mapper will use as
   `sourceNodeId`.
3. `process_add_vdm` with `sourceNodeId`, `schema` and `mappings`. In a batch, add the source
   first. It rejects `text` mode on a non-string target.
4. `validate_process` compiles the mappings and reports a missing source schema.

A Process Variable can be a source only when the draft already declares it: the MCP tools cannot
add Process Variables.

## Gotchas
- A Task as the source maps the Task's whole result object, not its body. For Frends.HTTP.Request
  that object is `Result` with `Body`, `StatusCode` and `Headers`, so a schema that describes the
  response body compiles every mapping as `Result.<field>` and fails with CS1061 ("'Result' does
  not contain a definition for 'id'"), once per mapping. The editor may show only one of them;
  `validate_process` lists all. Put an Assign Variable shape such as `Read user from response body`
  (`#result[HTTP Request].Body`) between the Task and the mapper, give it the body schema, and map
  from it. This also keeps the mappings independent of the Task's result type (seen on 6.4.0.1164).
- The mapper sits between a trigger and a Return or Throw, like any execution shape.
- Review a mapping the assistant generated before saving; it guesses matches from names and
  descriptions.
- With "Strict schema validation" off, a result that misses the target schema passes silently. Turn
  it on where the next system rejects malformed input, and catch the failure like any other.

## Example
Validated on 6.4.0.1164 and run there end to end (Processes "Visual Mapper - fixed source" and "Test -
Companion VDM strict validation").

Source fields `order_id`, `customer_name`, `is_paid`, `lines[].product_id`, `lines[].quantity`;
target `dealId`, `title`, `paid`, `lineItems[].sku`, `lineItems[].qty`:

```json
{ "dealId":        { "mode": "text",   "value": "{{#source.order_id}}" },
  "title":         { "mode": "text",   "value": "Order {{#source.order_id}} for {{#source.customer_name}}" },
  "paid":          { "mode": "csharp", "value": "#source.is_paid" },
  "lineItems.sku": { "mode": "text",   "value": "{{#source.lines.product_id}}" },
  "lineItems.qty": { "mode": "csharp", "value": "#source.lines.quantity" } }
```


## Source of truth
- `https://docs.frends.com/reference/shapes/activity-shapes/visual-data-mapper.md`
- `https://docs.frends.com/guides/development/how-to-use-visual-data-mapper.md`
- MCP `get_guide('data-mapper')` and the `process_add_vdm` and `process_set_source_schema` schemas
