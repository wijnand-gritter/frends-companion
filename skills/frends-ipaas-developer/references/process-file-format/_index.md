# Process file format — index

How Frends serializes a Process, for reading an export or generating an importable one. Start with
[overview.md](overview.md). Validated against real 6.2 exports in [examples/](examples/).

| File | What / when to read |
| --- | --- |
| [overview.md](overview.md) | The two formats at a glance; provenance. Read first. |
| [bpmn-xml.md](bpmn-xml.md) | Format 1 (diagram only); shape→BPMN mapping; error pattern. |
| [proprietary-json.md](proprietary-json.md) | Format 2 (full Process); envelope; the `...Json` string rule. |
| [shape-type-codes.md](shape-type-codes.md) | JSON `Type` codes, cross-linked to each shape. |
| [parameter-encoding.md](parameter-encoding.md) | The `{mode,value}` model and `select` enum trap. |
| [confirmed-shape-parameters.md](confirmed-shape-parameters.md) | Real 6.2 per-shape parameter shapes. |
| [triggers-encoding.md](triggers-encoding.md) | `TriggersJson` per trigger; confirmed vs inferred. |
| [generation-checklist.md](generation-checklist.md) | Steps + caveats for emitting an importable file. |
| [node-naming.md](node-naming.md) | Node names must be unique process-wide; the import error and exemptions. |
| [structured-flow-rules.md](structured-flow-rules.md) | Gateway branches must nest properly (join at one node or terminate). |
| [exception-handler-rules.md](exception-handler-rules.md) | The four rules a Scope with a Catch must satisfy to import. |
| [unhandled-error-hook.md](unhandled-error-hook.md) | The unhandled-error Subprocess setting, as a Type 18 entry with no BPMN element. |
| [canvas-layout-conventions.md](canvas-layout-conventions.md) | DI conventions that make a generated canvas look hand-arranged. |
| [templates-and-imports.md](templates-and-imports.md) | Template vs Process export, conversions, what each import path validates, `#var` before `#env`. |
| [examples.md](examples.md) | What each bundled real export demonstrates. |
