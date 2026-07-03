# Frends project workspace

Scaffolded from the Frends Companion (`fc-integration`) plugin.

## First-time setup

1. Copy `.env.example` to `.env` and fill in your Frends Platform API credentials. Run `/fc-integration:connect` if you want a guided walkthrough.
2. Verify connectivity:

   ```bash
   bash <skill-base>/scripts/frends-env-check.sh
   bash <skill-base>/scripts/frends-connection-test.sh
   ```

   `<skill-base>` is the `frends-ipaas-developer` skill's directory, printed when the skill loads.

## What goes where

```
active-development/
  processes/   # Process exports you pull from the platform
  feedback/    # run/test output
preferred_connections.md   # registry of reusable connections/endpoints for the agent
.env           # your credentials (never committed)
CLAUDE.md      # workspace instructions for the agent
```

## Everyday commands

```bash
# list / pull / push Processes
bash <skill-base>/scripts/frends-process-list.sh --name "Order Sync"
bash <skill-base>/scripts/frends-process-pull.sh --guid <uuid> --version <n>
bash <skill-base>/scripts/frends-process-push.sh --file active-development/processes/<file>.json

# deploy / run / monitor
bash <skill-base>/scripts/frends-deploy.sh deploy --agent-group "$FRENDS_TEST_AGENT_GROUP_ID" --guid <uuid> --version <n>
bash <skill-base>/scripts/frends-deploy.sh run --id <deploymentId>
bash <skill-base>/scripts/frends-instances.sh list --agent-group "$FRENDS_TEST_AGENT_GROUP_ID" --state ShowFailed
```

See the skill's `references/guides/cli_tool_reference.md` for the full tool list and the promote-to-test workflow.

> The Platform API CLI scripts are scaffolded and not yet live-tested. Validate against your tenant's `/swagger` before relying on them in automation.
