# Frends Platform API CLI tool reference

These `frends-*.sh` scripts live in `scripts/` and wrap the Frends Platform API
(`https://<tenant>.frendsapp.com/api/v1`). They are the second route: use the Frends MCP server
first for what it covers, and these scripts for the rest or when MCP is absent
([tooling-routes.md](tooling-routes.md)). Never hand-craft `curl`.

Status: endpoints, parameters and response fields checked against the Frends 6.3.2 OpenAPI document
(`https://<tenant>.frendsapp.com/v1.0/swagger.json`, 92 operations). Read operations of every script
confirmed live on Frends 6.3.2.5468 with `frends-smoke-test.sh`. Operations that change the tenant
(push, deploy, activation, run, tags, Environment Variable values, acknowledge, create from template)
are not yet run live. If a script's behaviour differs from the tenant's document, trust the document
and fix the script.

Facts from the live run:

| Endpoint | Behaviour |
| --- | --- |
| `GET /processes` | returns every version, deleted and outdated ones included, each with its full BPMN; `frends-process-list.sh` shows live latest versions unless `--all` |
| `GET /processes/{guid}/versions/{v}/export` | HTTP 400 for a deleted version |
| `GET /process-deployments` | items carry `deploymentId`, `processGuid`, `processVersion`, `triggersActive` and a nested `agentGroup.id` |

## Prerequisites

- `curl` and `jq` installed.
- A `.env` in the workspace root (copy from the template's `.env.example`).
- The Platform API **enabled on the tenant**: Microsoft Entra ID app registration,
  an `Administrator` app role with admin consent granted, and IP allowlisting
  arranged with Frends support. See
  `https://docs.frends.com/reference/frends-platform-api/how-to-enable-frends-platform-api`.

## Authentication model

Frends uses **OAuth2 client-credentials**:

1. `frends-common.sh` POSTs to `https://login.microsoftonline.com/<FRENDS_AZURE_TENANT>/oauth2/token`
   with `client_id`, `client_secret`, `grant_type=client_credentials`, and
   `resource=<FRENDS_APPLICATION_URI>`.
2. The returned `access_token` is cached in `.frends-token-cache` (gitignored,
   `chmod 600`) until shortly before it expires.
3. Every Platform API call sends `Authorization: Bearer <token>`.

If a token fetch fails, the scripts stop rather than retry: repeated bad-auth calls can lock the
account. Fix credentials first.

Entra ID client credentials are the only authentication the Platform API accepts. Private
Application tokens (Administration > Private Applications) authenticate callers of APIs published
through Frends API Management; they do not open the Platform API.

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
| `FRENDS_TARGET_FRAMEWORK` | Process target framework, from a sample export (`net8.0` on 6.2, `net10.0` on 6.3). |
| `FRENDS_VERIFY_SSL` | `false` to pass `-k` to curl (corporate SSL inspection). Default `true`. |
| `FRENDS_TIMEOUT` | Optional curl timeout override (seconds). |
| `FRENDS_COMPANION_LOG_ACTIVITY` | `1` to append operations to `.activity-log/activity.jsonl`. |

## Scripts

| Script | What it does | Key endpoint(s) | Changes the tenant |
|--------|--------------|-----------------|---|
| `frends-env-init.sh` | Creates `.env` from `.env.example` (mode 600) and fills non-secret keys with `--set`; refuses the client secret. | none | no |
| `frends-smoke-test.sh` | Read-only run of every script against the tenant: PASS/FAIL table, export validated and reviewed, live OpenAPI drift check; log in `active-development/feedback/`. Stops on 401/403 or an unreachable tenant. | all read endpoints | no |
| `frends-env-check.sh` | Shows which `.env` vars are SET/UNSET (no values). | none | no |
| `frends-connection-test.sh` | Fetches a token, lists 1 Process. | `GET /processes?PageSize=1` | no |
| `frends-agentgroups.sh` | list (per Environment) / show Agent Groups. | `GET /environments`, `GET /environments/{id}/agent-groups`, `GET /agent-groups/{id}` | no |
| `frends-process-list.sh` | Lists live latest Process versions (filter by name/guid, paged; `--all` for every version). | `GET /processes` | no |
| `frends-process-pull.sh` | Exports one Process version, or several with `--batch --ids`. | `GET /processes/{guid}/versions/{ver}/export`, `GET /processes/{id}/export`, `GET /processes/batch-export` | no |
| `frends-process-push.sh` | Imports a Process export; `--conflict` defaults to `Error`. | `POST /processes/batch-import` | yes |
| `frends-deploy.sh` | list / show / deploy / undeploy / activate / deactivate / run. | `/process-deployments...` | yes, except list and show |
| `frends-instances.sh` | list / details / counts / acknowledge Process Instances. | `/instances/{agentGroupId}...` | acknowledge |
| `frends-env-vars.sh` | list / show / set Environment Variable values per Environment. | `/environment-variables...` | set |
| `frends-tags.sh` | get / all / add / set / remove tags. | `GET`, `PATCH`, `PUT`, `DELETE /tags` | add, set, remove |
| `frends-templates.sh` | list / export Process Templates; create a Process from one. | `/process-templates...` | create-process |
| `frends-api-specs.sh` | list / show / version of API specifications. | `/api-management/api-specifications...` | no |

Commands that change the tenant run only on the person's explicit confirmation.

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

## Not covered by a script
Present in the 6.3.2 OpenAPI document and left to the Control Panel or a later script: API
policies and keys, API specification publish and deploy, passthrough configurations, Private
Applications, Process variable updates on a deployment, instance comments, CSV export and delete,
Agent status and events, Process delete, Process Template create and update.
