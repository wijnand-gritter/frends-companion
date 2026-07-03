# Frends Platform API CLI tool reference

These `frends-*.sh` scripts live in `scripts/` and wrap the **Frends Platform API**
(`https://<tenant>.frendsapp.com/api/v1`). Prefer them over hand-crafted `curl`.

> **Status:** Scaffolded from the published Frends 6.2 Platform API reference
> (`https://docs.frends.com/reference/frends-platform-api`). **Not yet live-tested
> against a tenant.** Validate every endpoint against your own
> `https://<tenant>.frendsapp.com/swagger` before relying on these in automation.
> If a script's behavior differs from `/swagger`, trust `/swagger` and fix the script.

## Prerequisites

- `curl` and `jq` installed.
- A `.env` in the workspace root (copy from the template's `.env.example`).
- The Platform API **enabled on the tenant**: Microsoft Entra ID app registration,
  an `Administrator` app role with admin consent granted, and IP allowlisting
  arranged with Frends support. See
  `https://docs.frends.com/reference/frends-platform-api/how-to-enable-frends-platform-api`.

## Authentication model

Different from Boomi's per-request basic auth. Frends uses **OAuth2 client-credentials**:

1. `frends-common.sh` POSTs to `https://login.microsoftonline.com/<FRENDS_AZURE_TENANT>/oauth2/token`
   with `client_id`, `client_secret`, `grant_type=client_credentials`, and
   `resource=<FRENDS_APPLICATION_URI>`.
2. The returned `access_token` is cached in `.frends-token-cache` (gitignored,
   `chmod 600`) until shortly before it expires.
3. Every Platform API call sends `Authorization: Bearer <token>`.

If a token fetch fails, the scripts **stop** rather than retry — repeated bad-auth
calls can lock the account. Fix credentials first.

## .env variables

| Variable | Purpose |
|----------|---------|
| `FRENDS_TENANT` | Tenant name; base URL becomes `https://<tenant>.frendsapp.com`. |
| `FRENDS_API_BASE_URL` | Optional full base URL override (if the tenant URL is non-standard). |
| `FRENDS_AZURE_TENANT` | Azure AD tenant, e.g. `yourorg.onmicrosoft.com`. |
| `FRENDS_CLIENT_ID` | Entra ID app registration Application (client) ID. |
| `FRENDS_CLIENT_SECRET` | Client secret for that app registration. |
| `FRENDS_APPLICATION_URI` | The Application ID URI exposed by the app registration (the token `resource`). |
| `FRENDS_DEV_AGENT_GROUP_ID` / `FRENDS_TEST_AGENT_GROUP_ID` / `FRENDS_PROD_AGENT_GROUP_ID` | Agent Group IDs used for deploy / instance queries. |
| `FRENDS_DEV_ENVIRONMENT_ID` / `FRENDS_TEST_ENVIRONMENT_ID` / `FRENDS_PROD_ENVIRONMENT_ID` | Environment IDs used for env-var values. |
| `FRENDS_TARGET_FRAMEWORK` | Default Process target framework (e.g. `net8.0`). |
| `FRENDS_VERIFY_SSL` | `false` to pass `-k` to curl (corporate SSL inspection). Default `true`. |
| `FRENDS_TIMEOUT` | Optional curl timeout override (seconds). |
| `FRENDS_COMPANION_LOG_ACTIVITY` | `1` to append operations to `.activity-log/activity.jsonl`. |

## Scripts

| Script | What it does | Key endpoint(s) |
|--------|--------------|-----------------|
| `frends-env-check.sh` | Shows which `.env` vars are SET/UNSET (no values). | — |
| `frends-connection-test.sh` | Fetches a token, lists 1 Process. | `GET /processes?PageSize=1` |
| `frends-process-list.sh` | Lists Processes (filter by name/guid, paged). | `GET /processes` |
| `frends-process-pull.sh` | Exports a Process version to a local JSON file. | `GET /processes/{guid}/versions/{ver}/export` or `GET /processes/{id}/export` |
| `frends-process-push.sh` | Imports a Process export (create/new version). | `POST /processes/batch-import` |
| `frends-deploy.sh` | list / deploy / show / undeploy / activate / deactivate / run. | `/process-deployments...` |
| `frends-instances.sh` | list / details / counts of Process Instances. | `/instances/{agentGroupId}...` |
| `frends-env-vars.sh` | list / show / set Environment Variable values. | `/environment-variables...` |
| `frends-agentgroups.sh` | show (and tentatively list) Agent Groups. | `GET /agent-groups/{id}` |

## Typical promote-to-test workflow

```bash
# 1. confirm credentials and connectivity
bash scripts/frends-env-check.sh
bash scripts/frends-connection-test.sh

# 2. find the Process and its latest version
bash scripts/frends-process-list.sh --name "Order Sync"

# 3. (optional) pull the dev export for review / version control
bash scripts/frends-process-pull.sh --guid <uuid> --version <n>

# 4. ensure env-vars exist in the Test environment, then deploy to the Test Agent Group
bash scripts/frends-env-vars.sh list --name OrderApi
bash scripts/frends-deploy.sh deploy --agent-group "$FRENDS_TEST_AGENT_GROUP_ID" \
  --guid <uuid> --version <n> --description "Promote Order Sync to Test"

# 5. run once and watch instances
bash scripts/frends-deploy.sh list --agent-group "$FRENDS_TEST_AGENT_GROUP_ID"
bash scripts/frends-deploy.sh run --id <deploymentId>
bash scripts/frends-instances.sh list --agent-group "$FRENDS_TEST_AGENT_GROUP_ID" --state ShowFailed
```

## Deploy prerequisites (platform-enforced)

A deploy fails unless: every used **Environment Variable** has a value in the target
Environment; every used **Subprocess** is already deployed there; and the Process
**target framework** matches the Agent Group framework. Deploy Subprocesses before
their parent Process.

## Endpoints confirmed vs. to verify

- **Confirmed in the reference:** Processes (list/get/export/batch-export/batch-import/delete),
  ProcessDeployments (list/create/get/undeploy/execute/activation/variableUpdate/variables),
  ProcessInstances (list/details/counts/acknowledge/comment/export/delete),
  EnvironmentVariables (list/get/create/child/delete/patch/value-update),
  AgentGroups single GET.
- **To verify against /swagger:** the Agent Groups **list** route, the Environments
  list route, and the exact JSON body shape for env-var value updates per type.
