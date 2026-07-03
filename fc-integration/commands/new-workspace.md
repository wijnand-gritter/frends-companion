---
description: Set up your local Frends template folder and configure the command to spin up a new workspace profile
---

This command sets up the user's personal Frends project template (the **User Template**) and generates the global `/frends-init` command for spinning up new workspaces from it. It locates the plugin's **Reference Template** and copies it into the **User Template** location the user specifies.

## Workflow

### Step 1: Get Template Location

Use the AskUserQuestion tool:

**Question:** "Where would you like your Frends template folder to be stored?"
**Header:** "Template path"
**Options (in this order):**
1. **Current directory** - "Use this current working directory"
2. **~/frends-template** - "Default location in your home directory"
3. **~/Desktop/frends-template** - "On your Desktop for easy access"

The user can also select "Other" for a custom path.

### Step 2: Find the Reference Template Directory

- [ ] Load the `frends-ipaas-developer` skill. The loader prints a base directory line: `<install-path>/fc-integration/skills/frends-ipaas-developer`.
- [ ] Strip the trailing `/skills/frends-ipaas-developer` → that's the plugin root.
- [ ] Append `/template` → that's the Reference Template path.
- [ ] Verify it exists with `ls <path>` before proceeding.

Example: base dir `~/.claude/plugins/fc-integration/skills/frends-ipaas-developer` → Reference Template at `~/.claude/plugins/fc-integration/template/`.

If the skill fails to load or the template path doesn't exist, ask the user where the `fc-integration` plugin is installed. Call this resolved path `PLUGIN_REFERENCE_TEMPLATE_DIR`.

### Step 3: Copy Template to Workspace

**If the User Template folder doesn't exist:**
- Create it and copy all contents from `PLUGIN_REFERENCE_TEMPLATE_DIR/`.
- Tell the user to set up `.env` from `.env.example`.

**If it already exists — smart merge:**
- **PRESERVE**: `.env`, `.env.local`, `preferred_connections.md`, any custom files/instructions.
- **MERGE / UPDATE**: directory structure, `.gitignore`, `.env.example`, `README.md`, `CLAUDE.md`, `.claude/settings.json`.
- **ASK** about conflicts when unsure; err toward preserving user content.
- Report what was updated vs preserved.

### Step 4: Generate Global Command

Create `~/.claude/commands/frends-init.md`:

```markdown
---
description: Create a new Frends project from your personal template
allowed-tools: Bash
---

Scaffold a new Frends project by copying the designated template into the current working directory.

## Pre-flight Checks

1. Verify the template exists at: {{USER_TEMPLATE_PATH}}
2. Verify the current directory is safe (not inside .git, not the template workspace itself)

## Execution

\`\`\`bash
rsync -av --exclude='.git' --exclude='.frends-token-cache' --exclude='hook-logs' "{{USER_TEMPLATE_PATH}}/" .
\`\`\`

## Post-Setup

Tell the user: if your .env is set up, you are ready to build.
TIP: if permission prompts feel frequent, /exit and relaunch — the workspace permission settings only take effect after a fresh session.
```

Replace `{{USER_TEMPLATE_PATH}}` with the actual User Template path.

### Step 5: Confirm Setup

Tell the user:
- Their template is at: [path]
- `/frends-init` is now available globally
- They can run `/frends-init` from any empty directory to start a new Frends project
- They can re-run `/fc-integration:new-workspace` anytime to update their template

## Notes

- Can be run multiple times to update the template.
- The user's `.env` credentials are NEVER overwritten.
- The generated `/frends-init` command is independent of the plugin location.
- The User Template lives outside the plugin, so plugin updates don't overwrite it; re-run this command to merge in updates from the plugin's Reference Template.
