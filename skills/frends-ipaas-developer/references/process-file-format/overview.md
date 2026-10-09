# Process file formats — overview

How Frends serializes a Process to a file, so you can read an export or generate an importable one.
There are two distinct formats; knowing which is which prevents the most common mistake: trying to
get functionality out of a file that only carries the diagram.

## Provenance
The structural mapping is validated against real Frends 6.2 exports (FrendsVersion 6.2.3.3649,
net8.0): a Subprocess and a full HTTP API Process (both in `examples/`), plus an **"All Icons" palette
export** that placed all 11 triggers and ~20 shapes on one canvas. Shape Type codes and
parameter-mode statistics are also informed by 77 official 5.7 template files (FrendsTemplates repo).
Between these, the envelope, the `{mode, value}` encoding, every shape Type code in
[shape-type-codes.md](shape-type-codes.md), and all 11 trigger `$type`/`config` shapes in
[triggers-encoding.md](triggers-encoding.md) are **confirmed for 6.2**. A 6.3.2.5468 export,
[examples/mcp_rabbitmq_inclusive_export_6.3.json](examples/mcp_rabbitmq_inclusive_export_6.3.json), adds the Inclusive Decision (Types 15 and 16), the MCP Trigger and the
configured RabbitMQ Trigger with client certificate authentication. What remains unconfirmed (no
sample yet): the fully-configured key set for the AMQP trigger (its palette default was empty).
Validate that against a matching export or the tenant `/swagger`.

## The two formats at a glance
- **BPMN XML export (`.bpmn`)** — the diagram only: shapes, names, sequence flows, and layout. No
  Task parameters, no C#, no expressions, no trigger config. A documentation export; importing it
  recreates the diagram skeleton with no functionality. See [bpmn-xml.md](bpmn-xml.md).
- **Proprietary JSON export (`.json`)** — the full Process: the BPMN diagram plus the C# and
  per-shape parameters. The format for moving a working Process between tenants, and the only one
  that round-trips functionality. Available via the UI export action and via the Platform API
  `GET /api/v1/processes/{guid}/versions/{version}/export`; import via
  `POST /api/v1/processes/batch-import` (multipart, with an `importConflict` mode such as
  `NewVersion` or `NewInactiveElement`). See [proprietary-json.md](proprietary-json.md).

**Rule of thumb:** to generate something a developer can import and run, target the JSON. Use BPMN
XML only when the goal is a diagram for documentation or another BPMN tool.

## This spec, split
[bpmn-xml.md](bpmn-xml.md) · [proprietary-json.md](proprietary-json.md) ·
[shape-type-codes.md](shape-type-codes.md) · [parameter-encoding.md](parameter-encoding.md) ·
[confirmed-shape-parameters.md](confirmed-shape-parameters.md) ·
[triggers-encoding.md](triggers-encoding.md) · [generation-checklist.md](generation-checklist.md) ·
[examples.md](examples.md)
