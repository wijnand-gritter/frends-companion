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
- **Node names must be unique across the whole process**, including inside scopes; a duplicate
  fails import with "Node name ... already used by another node". Validate before delivery — see
  [node-naming.md](node-naming.md).
- **Gateway branches must nest properly**: each branch terminates (its own Return/Throw) or all
  branches reconverge at the same node; a nested gateway must not escape its enclosing region.
  Violations fail import with "All branches of decision node ... must join at the same node." See
  [structured-flow-rules.md](structured-flow-rules.md).
- **Never reference `#result[X]` after branches rejoin when X ran on only one branch** — the file
  imports as C# with definite-assignment checks and fails with CS0165 even inside runtime-guarded
  ternaries. Promote the value to a `#var` on the branch that produces it. See
  [../expressions/result-reference-scope.md](../expressions/result-reference-scope.md).
- **Initialize object variables with csharp `new JObject()`**, not json-mode `{}` — json mode
  yields a string at runtime. See [../shapes/assign-variable.md](../shapes/assign-variable.md).
- **Gateway conditions go on the gateway's own entry** (`{"expression": {mode, value}}`); labeled
  branch flows get Type 4 entries with empty `Parameters` and `IsDefault` flags. See
  [../shapes/exclusive-decision.md](../shapes/exclusive-decision.md).
- **Lay out the DI per [canvas-layout-conventions.md](canvas-layout-conventions.md)** so the
  generated canvas matches how developers arrange processes by hand.
- **Never bake secrets** into generated parameters. Use Environment Variable references
  (`{{#env.Group.Name}}` in text fields), let the tenant hold the values, and list each one in
  `RequiredEnvironmentVariables`.
