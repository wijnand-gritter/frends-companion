# frends-companion-developer

**Frends Companion** — a Claude Code plugin for Frends iPaaS development. It wraps the
`frends-ipaas-developer` skill with plugin-level commands, an agent, a project template, and a set of
Frends Platform API CLI tools.

Distributed through the [Conclusion marketplace](https://repo.virtualsciences.nl/ai-pilot/conclusion-marketplace).

> **Important:** Frends Companion is an unofficial, community developer offering. It is not an
> official Frends product and is not covered by any Frends support agreement or SLA. Provided as-is.
> "Frends" is a trademark of its respective owner; this project is not affiliated with or endorsed by
> Frends.

> **Maturity:** The knowledge skill is production-grade, but the Platform API CLI scripts are
> **scaffolded from the published Frends 6.2 Platform API reference and have not been live-tested
> against a tenant.** Validate them against your own `https://<tenant>.frendsapp.com/swagger` before
> using them in automation. See each script's header and
> `skills/frends-ipaas-developer/references/guides/cli_tool_reference.md`.

## Install

In any Claude Code session:

```bash
/plugin marketplace add https://repo.virtualsciences.nl/ai-pilot/conclusion-marketplace.git
/plugin install frends-companion-developer@conclusion
```

The first line only has to be run once per machine — if you already installed `solution-design` or a
customer pack from the Conclusion marketplace, skip straight to the second.

Then, in a new session:

```bash
/frends-companion-developer:connect        # set up Frends Platform API credentials
/frends-companion-developer:new-workspace  # create the project template + global /frends-init
```

Updates arrive automatically when you open a new Claude Code session, or on demand from the
`/plugin` menu.

### Trying it out without installing

```bash
claude --plugin-dir /path/to/frends-companion
```

## What it does

Frends Companion turns Claude into a hands-on Frends integration developer that can:

- Design BPMN 2.0 Process flows shape-by-shape, write correct Frends C# expressions and Code Tasks,
  and scaffold custom C# Tasks.
- Generate importable Frends 6.2 Process JSON files via the skill's generator.
- List, export (pull), and import (push) Processes through the Frends Platform API.
- Deploy Processes to Agent Groups, activate/deactivate Triggers, and run Processes.
- Query Process Instances for debugging, manage Environment Variables, and inspect Agent Groups.

The skill loads by itself whenever you mention Frends concepts — Processes, Subprocesses, Tasks,
Triggers, Agent Groups, `#result` / `#var` / `#env` expressions. You do not have to invoke it.

## Commands

| Command | Purpose |
|---------|---------|
| `/frends-companion-developer:connect` | Interactive Frends Platform API credentials setup |
| `/frends-companion-developer:new-workspace` | Create a reusable project template + global `/frends-init` command |
| `/frends-companion-developer:clean` | Clean development artifacts |

After running `new-workspace`, use `/frends-init` from any empty directory to scaffold a new project.

## What's inside

```
.claude-plugin/plugin.json   the manifest
commands/                    slash commands  (/frends-companion-developer:…)
agents/                      frends-canvas-arranger — wiring + layout review
skills/frends-ipaas-developer/
  references/                concepts, triggers, shapes, expressions, tasks, guides,
                             process-file-format — organised by entity so it's easy to extend
  scripts/                   Platform API CLI tools + the Process JSON generator
template/                    the workspace scaffold copied by new-workspace
changes/                     changelog fragments, one per merge request
```

The serialization spec (`skills/frends-ipaas-developer/references/process-file-format/`) is confirmed
against real Frends 6.2 exports.

## Credential handling

**Platform API credentials** live in a `.env` file: the Azure AD client id/secret, Application ID
URI, Azure tenant, your Frends tenant name, and Agent Group IDs. The CLI tools load credentials
internally (`source .env` inside bash) and exchange them for a short-lived bearer token; the agent
invokes the tools without reading the secret values.

The template's `.claude/settings.json` denies reading `.env*` and steers the agent away from
credential files. This is a convenience buffer, not a hard security boundary — `.env` is plaintext on
your machine. For stricter isolation use OS-level file permissions.

## How the Platform API works (summary)

1. The Platform API must be enabled per tenant (Entra ID app registration + admin app role + IP
   allowlisting via Frends support).
2. The scripts POST to `https://login.microsoftonline.com/<azure-tenant>/oauth2/token` with
   `grant_type=client_credentials` to obtain a bearer token.
3. They call `https://<tenant>.frendsapp.com/api/v1/...` with `Authorization: Bearer <token>`.

See `skills/frends-ipaas-developer/references/guides/cli_tool_reference.md`.

## Contributing

Extending the knowledge skill: `skills/frends-ipaas-developer/CONTRIBUTING.md`. Cutting a release:
[RELEASING.md](RELEASING.md). Open a merge request — CI validates the manifests, the shell and Python
syntax, and every relative Markdown link.

## License

See [LICENSE](LICENSE).
