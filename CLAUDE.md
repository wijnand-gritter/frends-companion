# frends-companion-developer

This is a Claude Code plugin for Frends iPaaS development. It contains a skill, commands, and agents. The intended audience of this CLAUDE.md is any user + AI combination that needs to understand or modify the plugin itself.

## Installation

```bash
/plugin marketplace add wijnand-gritter/frends-companion
/plugin install frends-companion-developer@frends-companion
```

This repo is both the plugin and its marketplace. `.claude-plugin/plugin.json` is the plugin manifest; `.claude-plugin/marketplace.json` lists the plugin with source `./`. A version bump in `plugin.json` reaches users; the marketplace entry carries no version.

Updates apply at the next Claude Code session, or manually from the `/plugin` menu.

## Structure

```
.claude-plugin/plugin.json  # Manifest (required)
commands/                   # Slash commands (/frends-companion-developer:command)
agents/                     # Custom agents
skills/                     # Agent skills (each oriented around a SKILL.md)
template/                   # Reference Template copied into a user workspace
.claude-plugin/marketplace.json  # Marketplace listing this plugin
.github/workflows/           # CI (scripts/check.sh) and releases
changes/                    # Changelog fragments (one per PR)
```

## Commands

- `/frends-companion-developer:new-workspace` - Sets up a template folder in a chosen location and generates a global `/frends-init` command.
- `/frends-companion-developer:connect` - Interactive Frends Platform API credentials setup.
- `/frends-companion-developer:clean` - Clean development artifacts.

After running `new-workspace`, users can invoke `/frends-init` from any empty directory to scaffold a new Frends project. When `new-workspace` is re-run, the AI merges updates intelligently, keeping existing preferences while bringing in new updates from the plugin.

## Guidelines

- Keep contents minimal and focused.
- Commands: generally user-invoked markdown files; the filename becomes the command name.
- Skills: folders with a SKILL.md, auto-invoked by context.
- Agents: markdown definitions for specialized tasks, auto-invoked by context.
- `CLAUDE.local.md` adds a personalization layer outside version control (e.g. pointing Claude at local reference assets specific to a machine).

## Terminology

Frends-specific vocabulary matters; generic BPMN/C# intuition often gets it wrong. Use these terms precisely: **Process**, **Subprocess**, **Task**, **Code Task**, **Trigger**, **Agent**, **Agent Group**, **Environment**, **Process Instance**, **Environment Variable**, **Process Variable**, **deployment**. A Process is authored only in the Development Environment, saved as a new version, then deployed to Agent Groups in other Environments. The runtime that executes a Process is an **Agent**, which lives in an **Agent Group**.

## Platform API note

Tenant work goes through three routes, chosen per operation: the Frends MCP server, the Platform API scripts, then generated files (`skills/frends-ipaas-developer/references/guides/tooling-routes.md`). With Frends' own `frends` plugin installed, its skills own the MCP workflows and the companion adds the house layer.

The CLI tools in `skills/frends-ipaas-developer/scripts/` talk to the Frends Platform API (`https://<tenant>.frendsapp.com/api/v1`). The Platform API is not enabled out of the box: it requires Microsoft Entra ID app registration, an admin app role, and IP allowlisting arranged with Frends support. Authentication is OAuth2 client-credentials against Azure AD, which returns a bearer token used on every Platform API call. See `skills/frends-ipaas-developer/references/guides/cli_tool_reference.md` and the `connect` command.

The Platform API scripts are checked against the Frends 6.3.2 OpenAPI document (`https://<tenant>.frendsapp.com/v1.0/swagger.json`, 92 operations) and confirmed live on 6.3.2.5468 with `frends-smoke-test.sh` (reads) and `frends-write-test.sh` (writes on a throwaway Process); each script header lists what is confirmed. `scripts/check_api_drift.py <swagger.json>` reports operations added or removed since, and script calls the document no longer has. Entra ID client credentials are the only authentication the Platform API accepts.

## Skill VERSION files

Each bundled skill tracks its version in its own `VERSION` file: `skills/frends-ipaas-developer/VERSION` and `skills/frends-reviewer/VERSION`. `frends-reviewer` reviews Processes and custom Tasks; its automatic checks reuse the developer skill's generator validator, so keep the two in step. Treat the skill as the source of truth for Frends platform knowledge; the plugin wraps it with commands, an agent, the Platform API CLI scripts, and a project template.
