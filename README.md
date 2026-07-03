# Frends Companion

A Claude Code plugin (and marketplace) for Frends iPaaS development, modeled on the structure of
Boomi's "Boomi Companion" (`bc-integration` / `boomi-companion`).

This repository is both the **marketplace** and the **plugin**:

- **`.claude-plugin/marketplace.json`** — the marketplace manifest; it lists the plugin below.
- **`fc-integration/`** — the plugin: the bundled `frends-ipaas-developer` skill, slash commands, the
  `frends-canvas-arranger` agent, a reusable project template, and scaffolded Frends Platform API CLI
  tools.

## Install

```bash
/plugin marketplace add wijnand-gritter/frends-companion
/plugin install fc-integration@frends-companion
```

Then run `/fc-integration:env-setup-guide` to configure Frends Platform API credentials, and
`/fc-integration:configure-template-workspace` to set up a project template and the global
`/freshies` scaffolder.

## What's inside the plugin

The `frends-ipaas-developer` skill is organized by entity (concepts, triggers, shapes, expressions,
tasks, guides, process-file-format) so it's easy to extend — see
`fc-integration/skills/frends-ipaas-developer/CONTRIBUTING.md`. The serialization spec
(`references/process-file-format/`) is confirmed against real Frends 6.2 exports.

## Status

The knowledge skill is mature and its serialization detail is confirmed for Frends 6.2. The Platform
API CLI scripts are **scaffolded from the published 6.2 Platform API reference and not yet
live-tested** against a tenant — validate each endpoint against your tenant's
`https://<tenant>.frendsapp.com/swagger` before relying on it. See
`fc-integration/skills/frends-ipaas-developer/references/guides/cli_tool_reference.md`.

> Unofficial community project. Not affiliated with or endorsed by Frends.
