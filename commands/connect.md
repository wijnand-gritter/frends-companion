---
description: Interactive guide for setting up Frends Platform API credentials
---

Guide the user through setup or re-setup of their `.env` file for Frends Platform API access.

The Platform API is the second route. When a Frends MCP server answers (`get_overview`), it covers building, inspecting, deploying, running and diagnosing; the Platform API is still needed for tags, templates, API specifications, Environment Variable values per Environment, exports and instance acknowledgement. Problems with the MCP connection itself go to the `frends:getting-connected` skill when the `frends` plugin is installed. Entra ID client credentials are the only authentication the Platform API accepts; Private Application tokens are for published APIs only.

## Steps

1. **Check current state**:
   - Ensure the `frends-ipaas-developer` skill is loaded (the `scripts/` directory comes from the skill).
   - Run `bash scripts/frends-env-check.sh` to see which variables are SET vs UNSET.
   - Run `bash scripts/frends-connection-test.sh` to test token retrieval and Platform API connectivity.
   - Inform the user of the current state.

2. **Ask the user what they want** (use the AskUserQuestion tool):
   - "Create/recreate .env with Frends credentials"
   - "Test connection to the Frends Platform API"
   - "Explain the credential fields"
   - "Do full setup"

3. **For credential setup**:
   - Have the user copy `.env.example` to a new file named `.env` in a text editor or IDE.
   - Explain each value and where to find it. Tell the user to paste each value into `.env` and save.
   - You will not be able to write credentials into `.env` yourself — project settings block reading/writing `.env`.

   Fields:
   - `FRENDS_TENANT` — your tenant name; the Control Panel URL is `https://<tenant>.frendsapp.com`.
   - `FRENDS_AZURE_TENANT` — your Azure AD tenant, e.g. `yourorg.onmicrosoft.com`.
   - `FRENDS_CLIENT_ID` — the Entra ID app registration's Application (client) ID (Azure Portal → App registrations → your app → Overview).
   - `FRENDS_CLIENT_SECRET` — a client secret for that app registration (Certificates & secrets). Store it safely; it is not retrievable later.
   - `FRENDS_APPLICATION_URI` — the Application ID URI exposed by the app (Expose an API). This is the token `resource`.
   - `FRENDS_DEV_AGENT_GROUP_ID` / `FRENDS_TEST_AGENT_GROUP_ID` / `FRENDS_PROD_AGENT_GROUP_ID` — Agent Group IDs. Find them in Control Panel, or via `bash scripts/frends-agentgroups.sh show --id <n>`.
   - `FRENDS_DEV_ENVIRONMENT_ID` / `FRENDS_TEST_ENVIRONMENT_ID` / `FRENDS_PROD_ENVIRONMENT_ID` — Environment IDs (used when setting Environment Variable values).
   - `FRENDS_TARGET_FRAMEWORK` — usually `net8.0` for Frends 6.x.
   - `FRENDS_VERIFY_SSL` — set `false` only if corporate SSL inspection blocks TLS verification.

4. **Important platform prerequisite**: The Platform API is **not enabled by default.** It needs an Entra ID app registration with an `Administrator` app role (admin consent granted) and IP allowlisting arranged with Frends support. If `frends-connection-test.sh` returns 401/403, walk the user to `https://docs.frends.com/reference/frends-platform-api/how-to-enable-frends-platform-api` before retrying — repeated bad-auth calls can lock the account.

5. **Confirm completion**:
   - Run `bash scripts/frends-connection-test.sh` to verify.
   - On success, ask: "What would you like to build or deploy?"
   - On failure, help troubleshoot based on the error message (token error → credentials/app registration; 401/403 → app role/consent/allowlisting; SSL error → VPN/SSL inspection).

## Notes

- Can be run multiple times for re-setup.
- The agent helps the user *find* credentials but does not write them to `.env` — the user edits the file.
- Never echo secret values back into the conversation.
