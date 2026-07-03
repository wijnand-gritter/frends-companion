# Changelog

All notable changes to fc-integration are documented here.

## 0.1.0 — initial scaffold

- Bundled the `frends-ipaas-developer` skill (Frends 6.2 platform knowledge: concepts, BPMN modeling, expressions, Task development, deployment, Process file format, Process JSON generator).
- Added plugin manifest and `frends-companion` marketplace manifest.
- Added slash commands: `connect`, `new-workspace`, `clean`.
- Added the `frends-canvas-arranger` agent for BPMN step-path integrity and layout review.
- Added a project template (`.env.example`, `CLAUDE.md`, `.claude/settings.json`, `README.md`, `preferred_connections.md`, `.gitignore`).
- Added scaffolded Frends Platform API CLI tools (`frends-*.sh`) and a `cli_tool_reference.md`. **Not yet live-tested against a tenant** — validate against your `/swagger` before relying on them.
