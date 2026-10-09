# frends-companion-developer

This is a Claude Code plugin for Frends iPaaS development. It contains a skill, commands, and agents. The intended audience of this CLAUDE.md is any user + AI combination that needs to understand or modify the plugin itself.

## Installation

Users add the Conclusion marketplace and install:

```bash
/plugin marketplace add https://repo.virtualsciences.nl/ai-pilot/conclusion-marketplace.git
/plugin install frends-companion-developer@conclusion
```

This repo is the plugin: its root holds `.claude-plugin/plugin.json`. The catalogue entry lives in
the separate `conclusion-marketplace` repo and points here by git URL, so a version bump here is
what reaches users — the catalogue does not have to change.

Updates are generally applied automatically when opening a new Claude Code session, or manually via the `/plugin` menu.

## Structure

```
.claude-plugin/plugin.json  # Manifest (required)
commands/                   # Slash commands (/frends-companion-developer:command)
agents/                     # Custom agents
skills/                     # Agent skills (each oriented around a SKILL.md)
template/                   # Reference Template copied into a user workspace
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

The CLI tools in `skills/frends-ipaas-developer/scripts/` talk to the **Frends Platform API** (`https://<tenant>.frendsapp.com/api/v1`). The Platform API is not enabled out of the box: it requires Microsoft Entra ID app registration, an admin app role, and IP allowlisting arranged with Frends support. Authentication is OAuth2 client-credentials against Azure AD, which returns a bearer token used on every Platform API call. See `skills/frends-ipaas-developer/references/guides/cli_tool_reference.md` and the `connect` command.

The Platform API scripts are **scaffolded against the published Frends 6.2 Platform API reference and have not been live-tested against a tenant.** Each script header says so. Validate endpoints against your own tenant's `https://<tenant>.frendsapp.com/swagger` before relying on them in automation, and confirm any list endpoints whose exact path is marked TODO in the script.

## Skill VERSION files

Each bundled skill tracks its version in its own `VERSION` file: `skills/frends-ipaas-developer/VERSION` and `skills/frends-reviewer/VERSION`. `frends-reviewer` reviews Processes and custom Tasks; its automatic checks reuse the developer skill's generator validator, so keep the two in step. Treat the skill as the source of truth for Frends platform knowledge; the plugin wraps it with commands, an agent, the Platform API CLI scripts, and a project template.
