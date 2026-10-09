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
4. Fill `UsedTasksJson` with every Task ref used, set `FrendsVersion`, `ProcessExecutionVersion`
   and `TargetFramework` to the values in a sample export of the target tenant (spec keys
   `frendsVersion`, `processExecutionVersion`, `targetFramework`; a 6.3 tenant exports `net10.0`),
   generate a new `UniqueIdentifier`.
5. Wrap in the correct envelope for the import path ([proprietary-json.md](proprietary-json.md)).

## Harvest before you build: ask for a sample export

When a planned process needs **any** ingredient whose serialization is not marked confirmed here -
a Task not yet harvested from this tenant (HTTP, SQL, Slack, ...), a trigger config, a loop or
other scope variant, a Shared State operation - **stop and ask the developer for a sample export
first**, either at project setup or the moment the gap surfaces. One throwaway process built in
the editor with the needed shapes and exported takes them two minutes and yields exact task GUIDs,
parameter skeletons, and shape encodings. Never work around a missing ingredient silently (e.g.
re-implementing an HTTP Task inside a Code Task) and never guess an encoding: a workaround ships
hidden design deviations, and a guess costs an import-fail roundtrip. State plainly: "I need an
export containing X before I can generate this correctly."

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
- **A Scope with a Catch has four wiring rules.** Two outgoing flows, the one to the
  `intermediateCatchEvent` emitted **before** the one to the `endEvent`; **exactly one node in the
  catch branch**, whose single outgoing flow targets that same `endEvent`; and no branching after
  the scope. A catch branch of two or more shapes fails even though it converges on the right node,
  so wrap them in a Scope. All four report "An exception handler must return to the same node as the
  source it's catching from", so assert them before delivering. See
  [exception-handler-rules.md](exception-handler-rules.md).
- **The unhandled-error Subprocess setting is a Type 18 entry with no BPMN element** (id
  `globalErrorHandler`); derive `ElementParameters` from the diagram alone and it is dropped. See
  [unhandled-error-hook.md](unhandled-error-hook.md).
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
- **Fill in `Description` and `Tags`** (the house rules for *what* to write are an organisation's
  choice; a sound default is one or two present-tense sentences saying what the process does and
  when it runs, never a change log, plus one tag per external system it touches, e.g.
  `["CRM", "ERP"]`, reusing existing tag names).
  **The platform gotcha is not optional:** an API-trigger process defaults its `Description` to the
  OpenAPI spec title and version (`"Orders API - 1.0.2"`). That is not a description. Replace it
  with a real one and keep the spec version as a trailing footnote, or every API process in the
  list is labelled with the same string.
- **Never bake secrets** into generated parameters. Use Environment Variable references
  (`{{#env.Group.Name}}` in text fields), let the tenant hold the values, and list each one in
  `RequiredEnvironmentVariables`.
- **Run the canvas arranger, then the reviewer, before delivering.** Do both after every
  generation or edit of a Process file, in this order:
  1. Launch the `frends-canvas-arranger` agent on the file. It checks the sequence-flow wiring and
     tidies the DI layout without deleting shapes.
  2. Run `frends-reviewer`'s `review_process.py` on the arranged file. It checks the file against
     the import wiring rules and the conventions in
     [../guides/best-practices.md](../guides/best-practices.md); fix blockers and majors first.
  Review last, so the findings describe the file the developer imports. If a fix changes shapes or
  flows, run both again.
- **Set `frendsVersion` and `targetFramework` to the tenant's values** (a sample export; MCP
  `get_overview` gives the version). The generator defaults to 6.2.3.3649 and `net8.0`, the values
  its encodings were confirmed against; on a 6.3 tenant pass `net10.0`. A generated file with
  `net10.0` and `6.3.2.5468` imports through the Platform API (confirmed (import)).
- **On the MCP route, do not generate a file.** Build the draft with the process builder tools;
  this checklist is the file route ([../guides/tooling-routes.md](../guides/tooling-routes.md)).
