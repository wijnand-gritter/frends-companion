# MCP Trigger

**Category:** trigger · **Baseline:** Frends 6.3 (serialization confirmed against a 6.3.2.5468 export)

## Purpose
Exposes a Frends Process as a **Model Context Protocol tool**: AI assistants and other MCP
clients can discover and invoke the Process directly. New in Frends 6.3, built on the official
`ModelContextProtocol.AspNetCore` library, integrated with normal Process logging.

## Pairing
The [AI Connector shape](../shapes/ai-connector.md) gained MCP tool discovery and calling in the
same release, so Processes can both *be* tools (this trigger) and *call* tools (the shape) -
from Agent Group Processes or external MCP servers.

## Access (6.3.1)
- Tool access can be granted to OAuth applications, so tokens from an external OAuth provider are
  accepted at the Agent MCP endpoint.
- An OAuth application can define MCP scopes; a token is honoured only when it carries every
  configured scope.
- The endpoint supports the MCP authorisation discovery flow for interactive clients.
- Authorisation filters accept wildcard groups such as `test.*`.

## Serialization
Confirmed against a 6.3.2.5468 export of a Process built through the MCP process builder
([../process-file-format/examples/mcp_rabbitmq_inclusive_export_6.3.json](../process-file-format/examples/mcp_rabbitmq_inclusive_export_6.3.json)).
BPMN `startEvent`; JSON `Type` 0, `SelectedTypeId: "McpTrigger"`; `TriggersJson` `$type: "McpTrigger"`.
The `Parameters` of the start shape and the trigger `config` carry the same six keys:

```json
{ "$type": "McpTrigger",
  "config": {
    "toolName": "companion_serialisation_harvest",
    "title": "Companion serialisation harvest",
    "description": "Tool description shown to the AI model.",
    "inputSchema": "{\"type\":\"object\",\"properties\":{\"orderId\":{\"type\":\"string\"}},\"required\":[\"orderId\"]}",
    "outputSchema": "{\"type\":\"object\",\"properties\":{\"status\":{\"type\":\"string\"}}}",
    "annotations": { "readOnly": true, "idempotent": true }
  },
  "name": "Receive companion harvest tool call", "id": "McpTrigger",
  "shouldNotLogParameters": false }
```

- All values are plain JSON, not `{mode, value}` leaves.
- `inputSchema` and `outputSchema` are JSON Schema documents stored as escaped strings.
  `annotations` is a JSON object of MCP tool annotations. The export shows `readOnly` and
  `idempotent`, the two that were set; the MCP builder's schema also names `destructive` and
  `openWorld`.
- `toolName` must be unique on the Agent, which matches tool names case-insensitively (MCP builder
  schema). Keep it to letters, digits, underscores and hyphens, at most 64 characters.
- The Process holds no access settings: no scopes, no OAuth application, no auth key. Access is
  granted outside the Process, through a Private Application Registration in the Control Panel.

## Source of truth
`https://docs.frends.com/release-notes/frends-6.3/new-features`; fetch the live trigger reference
via [../guides/staying-current.md](../guides/staying-current.md) for current configuration fields.
