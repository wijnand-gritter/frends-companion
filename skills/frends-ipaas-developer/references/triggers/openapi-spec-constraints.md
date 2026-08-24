# OpenAPI spec constraints for API Triggers

**Category:** trigger · **Baseline:** Frends 6.2/6.3 (confirmed against a production tenant; 6.3 raises OpenAPI support to 3.1.1 and adds mTLS auth options - the constraints below still applied on a 6.3 tenant)

## Purpose
The rules an OpenAPI document must satisfy before the spec editor accepts it and an
[API Trigger](api.md) activates on an Agent. Specs that validate fine in generic OpenAPI
tooling can still fail here; these constraints are Frends-specific.

## One operation, one process
A process accepts **at most one API Trigger** (the editor enforces it: "Only one API
Trigger is allowed per process"). Each OpenAPI operation therefore binds to its own
process. Model the spec accordingly: an API with five operations needs five processes.
Other trigger types can still be combined on a process; the limit applies to API
Triggers only. The document embedded in the trigger must be narrowed to that one
operation too, see the next section.

## The embedded document must describe exactly ONE operation
The API Trigger config carries `openApiDocument`: a copy of the OpenAPI document, and it is what
API Management uses to bind the Process to an operation. **It must contain only the single
operation that Process implements.** Embedding the whole API document breaks the binding:

- API Management reports **"API Spec not found"**.
- The Process is listed under **Unlinked processes**, and every affected Process is grouped under
  the *first* path in its embedded document, regardless of its own `routeTemplate`. Several
  Processes appearing under one unrelated operation is the tell.
- The editor fixes it when the trigger is deleted and re-added, because it then re-embeds only
  the selected operation. That manual repair is the symptom, not the fix.

Everything outside `paths` stays whole: `info`, `servers`, the complete `components` (all schemas
and responses, including ones the operation does not reference), `security` and all `tags` are
kept as-is. Only `paths` is narrowed to one path with one method.

```yaml
paths:
  /leads:            # exactly one path, exactly one method
    patch:
      ...
components:          # unchanged, complete
```

**When generating a Process file, slice the document per operation.** A confirmed-good way to
produce the editor's own serialization: take an editor-produced document as the skeleton, keep its
bytes outside `paths`, and regenerate the `paths` block with a YAML dumper that indents sequences
under their key (PyYAML: subclass `SafeDumper` and force `increase_indent(..., indentless=False)`,
`default_flow_style=False`, `sort_keys=False`, wide `width`). That reproduces the editor's `paths`
block byte for byte; verify by round-tripping the skeleton's own operation before trusting it.

## Schemas must have explicit properties (no composition)
Every schema reachable from a request body or response must carry a literal
`properties` map. Pure compositions - a schema whose top level is only `allOf` (or
`oneOf`/`anyOf`) - have no `properties` of their own, and trigger activation fails with:

```
Could not add trigger '<route>' on agent <name>: Value cannot be null. (Parameter 'source')
```

The trigger's `#trigger.data.*` reference list is derived from those properties; the
parser does not resolve compositions. Rules:

- **Flatten `allOf`** into standalone schemas with explicit `properties`, duplicating
  shared fields. The wire contract is unchanged; only the document shape differs.
- **Inline nested `$ref`s** (shared sub-objects like addresses). The known-good pattern
  keeps `$ref` only at the top level: `requestBody`/`response` → one flat schema in
  `components/schemas`, and response entries → `components/responses`.
- A flat schema also yields complete `#trigger.data.*` auto-complete in the editor.

## No YAML anchors or aliases
The spec editor's validator does not resolve YAML anchors (`&x`) and aliases (`*x`) and
reports the aliased nodes as malformed, e.g.:

```
5140001  Responses Object values must be of Response Object shape
```

Write every node out literally. Watch out for YAML **generators**: serializers commonly
emit anchors automatically when the same object instance appears more than once
(PyYAML does this by default; disable with a Dumper whose `ignore_aliases` returns true).

## Prefer concrete response status codes
The known-good pattern enumerates concrete codes (`'400'`, `'401'`, `'500'`, ...) rather
than a `default:` response. Whether `default` alone breaks activation is unverified;
when an activation fails on a spec that uses it, convert to concrete codes as part of
the diagnosis.

## Symptom → cause

| Symptom | Cause |
|---|---|
| "Only one API Trigger is allowed per process" | Second API Trigger on one process; split into one process per operation |
| Activation: "Value cannot be null. (Parameter 'source')" | A reachable schema without literal `properties` (pure `allOf`/composition) |
| Editor 5140001 "must be of Response Object shape" | YAML anchors/aliases in the document |

## Known-good skeleton

```yaml
paths:
  /thing:
    post:
      operationId: createThing
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/thing'    # flat schema, explicit properties
        required: true
      responses:
        '201': { description: Created, content: { application/json: { schema: { $ref: '#/components/schemas/thingResponse' } } } }
        '400': { $ref: '#/components/responses/BadRequest' }
        '500': { $ref: '#/components/responses/InternalServerError' }
components:
  schemas:
    thing:            # type: object, literal properties, nested objects inlined
    thingResponse:    # idem
    error:            # idem
  responses:
    BadRequest:           { description: Bad Request, content: { application/json: { schema: { $ref: '#/components/schemas/error' } } } }
    InternalServerError:  { description: Internal Server Error, content: { application/json: { schema: { $ref: '#/components/schemas/error' } } } }
```

## Related
[api.md](api.md) · [parameter-fields.md](parameter-fields.md) ·
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md)

## Source of truth
Behavior confirmed on Frends 6.2. For current parser behavior, test against the tenant;
the platform docs do not document these constraints explicitly.
