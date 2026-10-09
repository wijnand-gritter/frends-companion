---
description: Detect the route to the Frends tenant and set up Platform API credentials in .env
---

Find out which route reaches the tenant and set up `.env` for the Platform API route. Run it from the workspace root, or from the User Template to give every new workspace the same `.env`.

## Rules

- Never ask for, read, write or echo `FRENDS_CLIENT_SECRET`. The user types it into `.env`.
- Fill non-secret values only through `frends-env-init.sh`. Project settings block reading `.env` directly.
- On a 401, a 403 or a token error, stop after the first attempt. Repeated bad-auth calls can lock the account.

## Steps

1. Load the `frends-ipaas-developer` skill. Scripts below are `bash <skill-base>/scripts/<name>`.

2. Detect the routes:

   | Check | Pass means |
   |---|---|
   | a `*get_overview` MCP tool answers | MCP route available |
   | `frends-env-check.sh` shows the credential keys SET and `frends-connection-test.sh` passes | Platform API route available |

   Report both results. With MCP available, the Platform API is optional: it adds Templates, tags, API management, batch export and instance housekeeping (see `references/guides/tooling-routes.md`). Ask whether to set it up.

3. Create `.env` and fill the non-secret values:
   - Run `frends-env-init.sh` to create `.env` from `.env.example` (mode 600) when it is missing.
   - With MCP available, take the ids from `get_overview` and pass them with `--set`:

     | Key | Source in `get_overview` |
     |---|---|
     | `FRENDS_DEV_ENVIRONMENT_ID`, `FRENDS_TEST_ENVIRONMENT_ID`, `FRENDS_PROD_ENVIRONMENT_ID` | `environments[].id`, matched on `displayName` |
     | `FRENDS_DEV_AGENT_GROUP_ID`, `FRENDS_TEST_AGENT_GROUP_ID`, `FRENDS_PROD_AGENT_GROUP_ID` | `environments[].agentGroups[].id` |

     Ask the user which Environment is which when the names do not say Development, Test or Production, or when an Environment has more than one Agent Group.
   - Ask the user for `FRENDS_TENANT`, `FRENDS_AZURE_TENANT`, `FRENDS_CLIENT_ID` and `FRENDS_APPLICATION_URI`, then pass them with `--set`.

   | Key | Where to find it |
   |---|---|
   | `FRENDS_TENANT` | the Control Panel URL `https://<tenant>.frendsapp.com` |
   | `FRENDS_AZURE_TENANT` | the Entra ID tenant, for example `yourorg.onmicrosoft.com` |
   | `FRENDS_CLIENT_ID` | Azure Portal, App registrations, the app, Overview, Application (client) ID |
   | `FRENDS_APPLICATION_URI` | the app's Expose an API page, Application ID URI |
   | `FRENDS_CLIENT_SECRET` | the app's Certificates & secrets page; the user pastes it into `.env` |
   | `FRENDS_TARGET_FRAMEWORK` | `net8.0` for Frends 6.x |
   | `FRENDS_VERIFY_SSL` | `false` only when SSL inspection breaks TLS |

4. Ask the user to open `.env`, paste `FRENDS_CLIENT_SECRET` and save. Wait for confirmation.

5. Verify: run `frends-env-check.sh`, then `frends-connection-test.sh`.

   | Result | Next step |
   |---|---|
   | pass | report the routes available and ask what to build |
   | token error | check client id, secret, Azure tenant, application URI |
   | 401 or 403 | check Platform API enablement, the Administrator app role with admin consent and IP allowlisting: `https://docs.frends.com/reference/frends-platform-api/how-to-enable-frends-platform-api` |
   | curl exit 35 | check VPN or SSL inspection; `FRENDS_VERIFY_SSL=false` as a last resort |

## Notes

- Safe to rerun; existing values are kept unless the user asks to replace one (`--force`).
- The Platform API accepts Entra ID bearer tokens only. Private Application tokens work for published APIs, not for the Platform API.
