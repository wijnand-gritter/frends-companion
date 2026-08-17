# MCP Trigger

**Category:** trigger · **Baseline:** Frends 6.3 (docs only - **serialization not yet confirmed**)

## Purpose
Exposes a Frends Process as a **Model Context Protocol tool**: AI assistants and other MCP
clients can discover and invoke the Process directly. New in Frends 6.3, built on the official
`ModelContextProtocol.AspNetCore` library, integrated with normal Process logging.

## Pairing
The [AI Connector shape](../shapes/ai-connector.md) gained MCP tool discovery and calling in the
same release, so Processes can both *be* tools (this trigger) and *call* tools (the shape) -
from Agent Group Processes or external MCP servers.

## Serialization
**Not confirmed against an export.** Per the harvest-first rule in
[../process-file-format/generation-checklist.md](../process-file-format/generation-checklist.md):
do not generate or edit this trigger in a process file until the user provides a sample export of
a configured MCP Trigger. Record the confirmed `$type`/`config` here and in
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md) once
harvested.

## Source of truth
`https://docs.frends.com/release-notes/frends-6.3/new-features`; fetch the live trigger reference
via [../guides/staying-current.md](../guides/staying-current.md) for current configuration fields.
