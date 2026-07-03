# fc-integration

**Frends Companion** — a Claude Code plugin for Frends iPaaS development. It wraps the `frends-ipaas-developer` skill with plugin-level commands, an agent, a project template, and a set of Frends Platform API CLI tools.

> **Important:** Frends Companion is an unofficial, community developer offering. It is not an official Frends product and is not covered by any Frends support agreement or SLA. Provided as-is. "Frends" is a trademark of its respective owner; this project is not affiliated with or endorsed by Frends.

> **Maturity:** The knowledge skill is production-grade, but the Platform API CLI scripts are **scaffolded from the published Frends 6.2 Platform API reference and have not been live-tested against a tenant.** Validate them against your own `https://<tenant>.frendsapp.com/swagger` before using them in automation. See each script's header and `skills/frends-ipaas-developer/references/guides/cli_tool_reference.md`.

## What it does

Frends Companion turns Claude into a hands-on Frends integration developer that can:

- Design BPMN 2.0 Process flows shape-by-shape, write correct Frends C# expressions and Code Tasks, and scaffold custom C# Tasks.
- Generate importable Frends 6.2 Process JSON files via the skill's generator.
- List, export (pull), and import (push) Processes through the Frends Platform API.
- Deploy Processes to Agent Groups, activate/deactivate Triggers, and run Processes.
- Query Process Instances for debugging, manage Environment Variables, and inspect Agent Groups.

## Related

| Component | Description |
|-----------|-------------|
| `frends-ipaas-developer` (bundled skill) | Frends platform knowledge: concepts, BPMN modeling, expressions, Task development, deployment, and Process file format. |

## Installation

```bash
/plugin marketplace add wijnand-gritter/frends-companion
/plugin install fc-integration@frends-companion
```

Or browse and install via `/plugin` interactively. Replace `wijnand-gritter` with the GitHub org/user where you host these repos.

### Local development / trying it out

```bash
claude --plugin-dir /path/to/fc-integration
```

## Commands

| Command | Purpose |
|---------|---------|
| `/fc-integration:env-setup-guide` | Interactive Frends Platform API credentials setup |
| `/fc-integration:configure-template-workspace` | Create a reusable project template + global `/freshies` command |
| `/fc-integration:tidy-up` | Clean development artifacts |

After running `configure-template-workspace`, use `/freshies` from any empty directory to scaffold a new project.

## Credential handling

**Platform API credentials** live in a `.env` file: the Azure AD client id/secret, Application ID URI, Azure tenant, your Frends tenant name, and Agent Group IDs. The CLI tools load credentials internally (`source .env` inside bash) and exchange them for a short-lived bearer token; the agent invokes the tools without reading the secret values.

The template's `.claude/settings.json` denies reading `.env*` and steers the agent away from credential files. This is a convenience buffer, not a hard security boundary — `.env` is plaintext on your machine. For stricter isolation use OS-level file permissions.

## How the Platform API works (summary)

1. The Platform API must be enabled per tenant (Entra ID app registration + admin app role + IP allowlisting via Frends support).
2. The scripts POST to `https://login.microsoftonline.com/<azure-tenant>/oauth2/token` with `grant_type=client_credentials` to obtain a bearer token.
3. They call `https://<tenant>.frendsapp.com/api/v1/...` with `Authorization: Bearer <token>`.

See `skills/frends-ipaas-developer/references/guides/cli_tool_reference.md`.

## License

See [LICENSE](LICENSE).
