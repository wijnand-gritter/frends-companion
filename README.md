# frends-companion-developer

This plugin turns Claude Code into a Frends developer who already knows the platform. It writes
correct expressions and Code Tasks, designs BPMN processes shape by shape, generates process files
you can import, and drives the Frends Platform API from your terminal.

The reason it exists: generic C# and BPMN knowledge gets Frends wrong. Ask any model to write a loop
or reference an earlier result and it invents syntax. The bundled `frends-ipaas-developer` skill
carries the real vocabulary and the traps, verified against Frends 6.2 exports.

It is installed from the Conclusion marketplace, which also carries the solution design plugins.
That catalogue's
[README](https://repo.virtualsciences.nl/ai-pilot/conclusion-marketplace/-/blob/main/README.md)
covers the rest of what the integration team maintains.

## Before you start

You need Claude Code, either in the terminal or in the desktop app, and access to our GitLab.

The skill itself needs nothing else. The Platform API tools are shell scripts and the process
generator is a Python script, so if you want those, install these once:

| Tool | macOS | Windows |
|---|---|---|
| bash | preinstalled | comes with [Git for Windows](https://gitforwindows.org/), or use WSL |
| curl | preinstalled | preinstalled on Windows 10 and later |
| jq | `brew install jq` | `winget install jqlang.jq`, or [jqlang.github.io/jq](https://jqlang.github.io/jq/download/) |
| Python 3.9 or newer | preinstalled, or `brew install python` | [python.org/downloads](https://www.python.org/downloads/), tick "Add python.exe to PATH" |

The Python side uses the standard library only, so there is nothing to pip install. On Windows, run
the shell scripts from Git Bash or WSL rather than PowerShell.

Check them:

```bash
bash --version
curl --version
jq --version
python3 --version
```

## Install

### Letting git in, once per machine

The catalogue is served over HTTPS, so git needs a token for our GitLab. Create a personal access
token in GitLab, under your avatar, then Edit profile, then Access tokens. The `read_repository`
scope is enough. Then:

```bash
git config --global url."https://oauth2:<TOKEN>@repo.virtualsciences.nl/ai-pilot".insteadOf "https://repo.virtualsciences.nl/ai-pilot"
```

Use this rewrite rather than a credential helper or keychain entry. Claude Code runs its background
update with credential helpers switched off, so a keychain entry is invisible to it and your plugins
quietly stop updating while your own `git pull` keeps working.

Skip this if you already set it up for another Conclusion plugin.

### In the terminal

```bash
claude plugin marketplace add https://repo.virtualsciences.nl/ai-pilot/conclusion-marketplace.git
claude plugin install frends-companion-developer@conclusion
```

Skip the first line if you already added the catalogue for `solution-design` or a customer pack. The
same commands work inside a session as `/plugin marketplace add ...` and `/plugin install ...`.

Restart Claude Code, then set yourself up:

```bash
/frends-companion-developer:connect        # Platform API credentials, step by step
/frends-companion-developer:new-workspace  # project template plus a global /frends-init
```

### In the desktop app or Cowork

The desktop app cannot read a git catalogue. It runs plugins synced to your account as `.plugin`
files, which are a zipped plugin directory under a different extension. This repository is the plugin
directory, so package its root:

```bash
git clone https://repo.virtualsciences.nl/ai-pilot/frends-companion.git
cd frends-companion
zip -r ~/frends-companion-developer.plugin . -x ".git/*" -x "*.DS_Store" -x "*__pycache__*"
```

On Windows, right-click the folder, choose Send to, then Compressed folder, and rename the resulting
`.zip` to `.plugin`.

Share the file in a chat, or ask Claude in a Cowork session to package and deliver it. It arrives as
a card with an accept button, and accepting saves it to your account for every chat and desktop
session afterwards.

### Keeping it up to date

Git is the master copy, and the two channels follow it differently.

The terminal updates in the background and applies at your next session. To pull now:

```bash
claude plugin update frends-companion-developer
```

The desktop app freezes at the moment you packaged it, so re-package and accept again when this
plugin changes.

### Trying it without installing

```bash
claude --plugin-dir /path/to/frends-companion
```

Colleagues who installed this from the old public `fc-integration` marketplace should remove it. The
plugin moved here and was renamed, so the two copies fight over the same skill.

## What you get

The skill loads by itself. Mention a process, a subprocess, a trigger, an agent group or a `#result`
expression and it is there, so there is nothing to invoke.

With it, Claude can:

- Design a BPMN 2.0 process flow shape by shape, and write the C# expressions and Code Tasks inside
  it.
- Scaffold a custom C# task as a NuGet package.
- Generate a process JSON file you can import into Frends 6.2 straight away.
- List, pull and push processes over the Platform API.
- Deploy a process to an agent group, activate or deactivate its trigger, and run it.
- Query process instances when something failed, read and set environment variables, and inspect
  agent groups.

The `frends-canvas-arranger` agent reviews a generated process before you import it. It checks every
shape is wired and tidies the layout, which matters because a file that imports cleanly can still be
unreadable on the canvas.

## Commands

| Command | What it does |
|---|---|
| `/frends-companion-developer:connect` | Walks you through the Platform API credentials and writes `.env` |
| `/frends-companion-developer:new-workspace` | Copies the project template somewhere you choose and writes a global `/frends-init` |
| `/frends-companion-developer:clean` | Removes development artefacts, keeps the folder structure |

Run `new-workspace` once. After that, `/frends-init` scaffolds a new Frends project from any empty
directory. Re-run `new-workspace` later and Claude merges the update into your template, keeping the
preferences you set.

## What is inside

```
.claude-plugin/plugin.json   the manifest
commands/                    the three slash commands
agents/                      frends-canvas-arranger
skills/frends-ipaas-developer/
  references/                concepts, triggers, shapes, expressions, tasks, guides,
                             process-file-format, one folder per entity
  scripts/                   eleven Platform API tools and the process generator
template/                    what new-workspace copies into your workspace
changes/                     one fragment per merge request
```

References are split by entity so extending them is obvious: a new trigger is a new file in
`references/triggers/`, and nothing else moves. `skills/frends-ipaas-developer/CONTRIBUTING.md`
explains the shape each file follows.

## Credentials

The Platform API tools read a `.env` holding your Entra ID client id and secret, the application ID
URI, the Azure tenant, your Frends tenant name and the agent group ids. They source that file inside
bash and exchange it for a short-lived bearer token. Claude runs the tools without ever reading the
secrets.

The template's `.claude/settings.json` blocks reading `.env*`. Treat that as a convenience, not a
security boundary. Your `.env` is plaintext on your disk, so use file permissions if you need real
isolation.

## Reaching the Platform API

Frends does not enable the Platform API for you. Someone has to register an Entra ID application,
grant it the admin app role, and ask Frends support to allowlist your IP address. Until that happens
the tools cannot connect, however correct your `.env` is.

Once enabled, each script posts to `https://login.microsoftonline.com/<azure-tenant>/oauth2/token`
with `grant_type=client_credentials`, then calls `https://<tenant>.frendsapp.com/api/v1/...` with the
bearer token it gets back.

`skills/frends-ipaas-developer/references/guides/cli_tool_reference.md` documents every script.

## Maturity

The knowledge is solid. The serialisation spec under `references/process-file-format/` is confirmed
against real 6.2 exports, and the 6.3 release notes are folded into the references they affect.

The Platform API scripts are not. They were written from the published 6.2 Platform API reference and
have never run against a live tenant. Check each endpoint against your own
`https://<tenant>.frendsapp.com/swagger` before you trust one in automation. Every script says so in
its header, and a few list endpoints are still marked TODO.

## Contributing

Run `bash scripts/check.sh` before you push. It validates the manifests, SemVer, the shell and
Python syntax, and every relative Markdown link. `git config core.hooksPath scripts/githooks` makes
git run it on every push, which matters because our GitLab has no runners yet and a pipeline
currently checks nothing.

Then open a merge request.

[RELEASING.md](RELEASING.md) covers cutting a version.

## Standing

This is a community project by integration developers at Conclusion. Frends neither endorses nor
supports it, no SLA covers it, and "Frends" belongs to its owner. Use it as-is.

MIT licensed, see [LICENSE](LICENSE).
