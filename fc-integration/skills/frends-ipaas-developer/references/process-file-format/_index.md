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
| [examples.md](examples.md) | What each bundled real export demonstrates. |
