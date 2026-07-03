# Generating an importable Process: checklist and caveats

The generator at `scripts/generate_process.py` implements this for linear flows (its docstring
documents the spec format; `scripts/sample_spec.json` is a starting point). It is validated to
round-trip and match the real exports field-for-field; use it for linear processes and hand-author
decisions, scopes, and subprocess calls from this reference. See
[../guides/cli_tool_reference.md](../guides/cli_tool_reference.md).

## Steps to assemble a valid Process JSON
1. Emit the `Bpmn` XML: one `startEvent`, the shapes mapped via [bpmn-xml.md](bpmn-xml.md),
   `sequenceFlow` wiring, an `endEvent`, and a `bpmndi` layout block. Use fresh bpmn.io-style ids.
2. Emit `ElementParameters`: one entry per shape, matching ids, correct `Type`
   ([shape-type-codes.md](shape-type-codes.md)), correct `SelectedTypeId` (real Task ref for Tasks),
   and `Parameters` leaves as `{mode,value}` ([parameter-encoding.md](parameter-encoding.md)).
3. Emit `TriggersJson` for the start event ([triggers-encoding.md](triggers-encoding.md)).
4. Fill `UsedTasksJson` with every Task ref used, set `FrendsVersion`/`TargetFramework` to the
   target tenant (6.2, net8.0), generate a new `UniqueIdentifier`.
5. Wrap in the correct envelope for the import path ([proprietary-json.md](proprietary-json.md)).

## Caveats to state to the developer every time
- **Task references are tenant-specific.** The GUID in `/ProcessTask/{guid}/v{n}` is assigned per
  tenant and not portable (see Type 1 in [shape-type-codes.md](shape-type-codes.md)). Never fabricate
  or copy one from a template. Harvest the real ref from a target-tenant export with
  `scripts/generate_process.py --harvest <export.json>`, which records the ref plus a full,
  version-correct parameter skeleton in `tenant_tasks.json`. `scripts/task_registry.json` holds
  marketplace-tenant GUIDs only, as a last-resort hint; the generator warns when it falls back. Set
  `PackageVersion` to a version the tenant has installed, and include each referenced Task in
  `LinkedTasks`. The `LinkedTasks` dictionary **key must equal the process `UniqueIdentifier`** (a
  mismatched key fails with "Sequence contains no matching element"); what matches the task *ref* is
  the inner `Id`.
- **Every `ElementParameters` entry must carry the full standard field set**, not just
  `Id`/`Type`/`Parameters`/`SelectedTypeId`: also `PromoteResultAs`, `Name`, `Description`,
  `IsDefault`, `ShouldRetry`, `MaxRetryCount`, `ShouldNotLogResult`, `ShouldDispose` (mostly null;
  Tasks use `ShouldRetry: false` and set `Name` to the shape label; Returns have `Name: null`).
  Omitting these fails the import. The generator emits them via its `_entry` helper.
- **A Task's `Parameters` must include every parameter group** from the method signature (e.g.
  Frends.HTTP.Request needs `input`, `options`, `cancellationToken`), not just the groups you
  changed. A harvested skeleton has them all; the generator deep-merges your values onto it. The
  `options` field set is version-specific — another reason to harvest rather than hand-write.
- Use the `Processes` envelope for a tenant import and `ProcessTemplates` only for marketplace
  templates. Write the file with a **UTF-8 BOM**.
- For a Subprocess set `IsSubprocess: true` and the packaging fields; for a full Process leave those
  empty.
- Regenerate GUIDs and element ids for a genuinely new Process; reuse them only to create a new
  version of an existing one (and choose the matching `importConflict` mode).
- The envelope, parameter encoding, full-Process and Subprocess field sets, the Manual and HTTP API
  Triggers, and Subprocess calls are **confirmed** for 6.2. Only Schedule, File, and Conditional
  Trigger configs remain **inferred**. Validate generated output by importing into a dev Agent Group
  and fixing whatever the importer reports.
- **Never bake secrets** into generated parameters. Use Environment Variable references
  (`{{#env.Group.Name}}` in text fields), let the tenant hold the values, and list each one in
  `RequiredEnvironmentVariables`.
