---
description: Set up your Frends User Template with its .env and generate the global /frends-init command
---

Set up the user's personal Frends project template (the User Template), give it one `.env` that every workspace inherits, and generate the global `/frends-init` command that scaffolds a workspace from it.

## Rules

- Never ask for, read, write or echo `FRENDS_CLIENT_SECRET`.
- Never overwrite an existing `.env` or `.env.local`.

## Steps

1. Ask where the User Template goes (AskUserQuestion, header "Template path"):

   | Option | Description |
   |---|---|
   | Current directory | use this working directory |
   | `~/frends-template` | default location in the home directory |
   | `~/Desktop/frends-template` | on the Desktop |

2. Find the Reference Template:
   - Load the `frends-ipaas-developer` skill. Its base directory is `<install-path>/frends-companion-developer/<version>/skills/frends-ipaas-developer`.
   - Strip `/skills/frends-ipaas-developer` and append `/template`.
   - Check the path exists with `ls`. When it does not, ask the user where the plugin is installed.

3. Copy the Reference Template into the User Template:

   | User Template | Action |
   |---|---|
   | does not exist | create it and copy everything |
   | exists | preserve `.env`, `.env.local`, `preferred_connections.md` and custom files; update the folder structure, `.gitignore`, `.env.example`, `README.md`, `CLAUDE.md`, `.claude/settings.json`; ask on conflicts |

   Report what was updated and what was preserved.

4. Set up `.env` in the User Template: run the `/frends-companion-developer:connect` steps with the User Template as the working folder. Every workspace scaffolded from it gets a copy. Skip when the user only works on the MCP route; `connect` can run later in a workspace.

5. Write `~/.claude/commands/frends-init.md`, with `{{USER_TEMPLATE_PATH}}` replaced by the User Template path:

   ````markdown
   ---
   description: Create a new Frends workspace from your User Template
   allowed-tools: Bash
   ---

   Scaffold a Frends workspace in the current directory from the User Template.

   ## Pre-flight

   1. The User Template exists at {{USER_TEMPLATE_PATH}}.
   2. The current directory is not inside `.git` and is not the User Template.

   ## Execution

   ```bash
   rsync -av --exclude='.git' --exclude='.frends-token-cache' --exclude='hook-logs' "{{USER_TEMPLATE_PATH}}/" .
   ```

   ## Post-setup

   1. Load the `frends-ipaas-developer` skill.
   2. When the workspace has no `.env`, run `bash <skill-base>/scripts/frends-env-init.sh` to create it from `.env.example`.
   3. Detect the routes: a `*get_overview` MCP tool answers; `frends-env-check.sh` and `frends-connection-test.sh` pass. Report which routes are available.
   4. When the Platform API route is wanted and fails, run `/frends-companion-developer:connect`.
   5. Tell the user to restart the session if permission prompts are frequent: workspace settings load at session start.
   ````

6. Report:
   - the User Template path
   - whether `.env` is set up, and which routes passed
   - `/frends-init` scaffolds a workspace from any empty directory
   - rerun `/frends-companion-developer:new-workspace` to merge plugin updates into the User Template

## Notes

- The User Template lives outside the plugin, so plugin updates never overwrite it.
- The generated `/frends-init` copies the User Template's `.env` into each workspace. Rotate the secret in the User Template and in existing workspaces.
