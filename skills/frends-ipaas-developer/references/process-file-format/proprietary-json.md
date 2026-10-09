# Format 2: proprietary JSON (full Process)

There are two envelope shapes. A single-Process (or Subprocess) export wraps in `Processes`, with the
linked data and the schema marker at the top level. This is what the UI export action and the
Platform API `/export` endpoint produce, confirmed against a real 6.2 export:
```
{ "Processes": [ { ...Process object, see below... } ],
  "LinkedTasks": { "<taskGuid>": { ...Task package metadata... } },
  "LinkedSubProcess": { },
  "Version": "Acc41" }                 // serialization/schema marker (stable across 5.7 and 6.2)
```
The template-import files in the FrendsTemplates repo use a different wrapper
(`{ "ProcessTemplates": [ { ..., "ProcessInfo": { "Process", "LinkedTasks", "LinkedSubProcess",
"Version" } } ] }`), but the inner `Process` object is the same substance. So: for a tenant export
expect `Processes`; for a marketplace template expect `ProcessTemplates`.

**Note:** 6.2 exports are written with a UTF-8 BOM. Parse with BOM-aware decoding (e.g. `utf-8-sig`)
or stripping will fail.

## Key fields inside a `Process` object (confirmed on the 6.2 export)
- `Bpmn`: the BPMN XML string from [Format 1](bpmn-xml.md) (the structure).
- `ElementParameters`: a JSON string holding an array of per-shape entries (the functionality).
- `TriggersJson`: a JSON string with the trigger configuration; `ManualTriggerJson` holds the manual
  trigger's parameter metadata when it defines parameters. See [triggers-encoding.md](triggers-encoding.md).
- `UsedTasksJson`: array of Task package references in use, e.g.
  `"/ProcessTask/8df5d07c-6c35-417c-b6c9-f0ce0721b9cd/v1"`.
- `RequiredEnvironmentVariables` and `StaticRequiredEnvironmentVariables`: arrays of `"Group.Name"`
  strings (e.g. `"SLACK_CONNECTION.token"`). Values are not exported; they live in the tenant.
  Secrets are externalized to [Environment Variables](../concepts/environment-variables.md), never
  inlined.
- `UniqueIdentifier` (GUID), `Version` (integer process version), `MajorVersion`/`MinorVersion`,
  `Description`, `Modified`, `Modifier`.
- `FrendsVersion` (e.g. `6.2.3.3649`), `ProcessExecutionVersion` (e.g. `6.2.10`), `TargetFramework`
  (`net8.0` in 6.2 exports, `net10.0` in 6.3 exports: confirmed on a 6.3.2.5468 export with
  `FrendsVersion` `6.3.2.5468`). Copy the three values from a sample export of the target tenant.
- Packaging fields, present on both Processes and Subprocesses (each compiles into a package):
  `AssemblyName`, `PackageId` (a sanitized name plus the GUID with dashes removed), `PackageVersion`.
  The distinguishing flag is `IsSubprocess` (true for a Subprocess), not the presence of these fields.
- `UsedSubprocessesJson`: records Subprocess calls, e.g. `{ "<subprocessGuid>": ["__localCall"] }`.

The model: `Bpmn` defines shapes and wiring by id; `ElementParameters` attaches behavior to each
shape by the same id; `TriggersJson` configures the start; `LinkedTasks` carries metadata for every
Task the shapes reference. To read a Process, parse `Bpmn`, `ElementParameters`, and `TriggersJson`
(all JSON/XML strings inside the outer JSON) and join on the BPMN element id.

## Critical for generation: the `...Json` string rule
Fields suffixed `...Json` are JSON **encoded as a string**, not native objects. `ElementParameters`,
`TriggersJson`, `ManualTriggerJson`, `UsedTasksJson`, `UsedSubprocessesJson`, and
`PromotedResultVariablesJson` must each be a string (e.g. `"[]"` or `"{}"`, not `[]` or `{}`).
Emitting any as a native array/object makes the importer reject the whole file with "does not seem to
be in JSON format". By contrast `Tags`, `RequiredEnvironmentVariables`, and
`StaticRequiredEnvironmentVariables` are native arrays, and `ProcessVariablesJson` is null when
unused.

See [shape-type-codes.md](shape-type-codes.md), [parameter-encoding.md](parameter-encoding.md), and
the [generation-checklist.md](generation-checklist.md).
