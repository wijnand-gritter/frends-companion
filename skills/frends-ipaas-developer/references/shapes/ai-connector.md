# AI Connector shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Calls an AI model from within a Process — Frends' native AI integration. Send prompts/data and use the
structured response downstream (classification, extraction, generation, simple RAG steps).

## Fields / configuration (confirmed keys)
- **useNativeAiMode** — toggle for native AI mode.
- **serviceType** — the backend (e.g. `frendsAi`; on-prem Ollama or Azure AI Inference are also
  supported per the guides).
- **modelName** — the model identifier (a GUID for Frends-hosted models).
- **systemPrompts** — array of prompt entries (`{mode,value}` text), e.g. a system prompt instructing
  a strict JSON response shape.
- **useCustomOptions** / **optionsJson** — optional model options as a JSON string.

Only provide data you intend the model to receive; see the tokenization/data guides. Frends logs AI
use in AI Audit Logs.

## New in 6.3: MCP tools and opt-in reasoning
A **Tools tab** lets the shape discover and call MCP tools - from Agent Group Processes
exposed via the [MCP Trigger](../triggers/mcp.md) or from external MCP servers. Reasoning
steps are **opt-in** to keep token usage and latency predictable. **Serialization of the
tool-selection keys is not confirmed** - harvest a configured export before generating them.

## Serialization
BPMN `task` (a plain task, not `businessRuleTask`); JSON `Type` **27**; `SelectedTypeId` = `NativeAi`.
Confirmed `Parameters` keys: `useNativeAiMode`, `useCustomOptions`, `optionsJson`, `serviceType`,
`modelName`, `systemPrompts[]`. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/ai-connector.md`,
`https://docs.frends.com/frends-development/ai-features.md`
