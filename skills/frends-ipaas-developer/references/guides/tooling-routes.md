# Guide: tooling routes

Every tenant operation goes through one of three routes. Choose the route per operation, in this
order, and name the route in the reply.

| Route | What it is | Available when |
| --- | --- | --- |
| MCP | the Frends MCP server: drafts, process builder, validation, promotion, deployment, runs, instances, Tasks, Environment Variables, guides | a tool whose name ends in `get_overview` answers (any server prefix, e.g. `mcp__Frends__get_overview`, `mcp__plugin_frends_frends__get_overview`) |
| Platform API | the `frends-*.sh` scripts over `https://<tenant>.frendsapp.com/api/v1` | `bash scripts/frends-connection-test.sh` passes |
| Files | `scripts/generate_process.py`, the [process file format](../process-file-format/) and manual import in the Control Panel | always |

## Detection
1. Call the `get_overview` tool once at the start of tenant work. An answer means MCP is the route
   for everything MCP covers.
2. When MCP is absent, or for an operation MCP does not cover, run `frends-env-check.sh` and
   `frends-connection-test.sh`. A pass means the Platform API route.
3. Otherwise use files, and say which steps the developer performs in the Control Panel.

## Fallback
- A missing tool, a connection error or a 404 on a tool moves the operation to the next route.
- A 401 or 403 stops the operation. Report it and check access before any retry; repeated bad
  authentication can lock the account. For MCP, the `frends:getting-connected` skill diagnoses the
  connection when it is installed.
- A validation or compilation error is a build finding, never a reason to change route.

## Route per operation

| Operation | MCP | Platform API | Files |
| --- | --- | --- | --- |
| Tenant overview, Environments, Agent Groups | `get_overview` | `frends-agentgroups.sh` | `.env` ids |
| Find a Process | `list_processes` | `frends-process-list.sh` | none |
| Read a Process | `get_process_data` (draft or deployment) | `frends-process-pull.sh` | an export file |
| Build or edit | `create_process_draft`, `process_*`, `process_batch_mutate`, `validate_process` | generate, then `frends-process-push.sh` | `generate_process.py`, manual import |
| Review | `get_process_data`, then `frends-reviewer` | `frends-process-pull.sh`, then `frends-reviewer` | `frends-reviewer` on the file |
| Promote a draft to Development | `create_process_from_draft` | `frends-process-push.sh` | manual import |
| Deploy to Test or Production | `deploy_process` | `frends-deploy.sh deploy` | Control Panel |
| Activate or deactivate triggers | `deploy_process` with `activateTriggers` | `frends-deploy.sh activate` / `deactivate` | Control Panel |
| Run | `start_process` | `frends-deploy.sh run` | Control Panel |
| Instances and diagnosis | `get_process_instances`, `get_process_instance_details` | `frends-instances.sh` | Control Panel |
| Acknowledge failed instances | none | `frends-instances.sh acknowledge` | Control Panel |
| Environment Variables: list, create | `list_environment_variables`, `create_environment_variable` | `frends-env-vars.sh list` | Control Panel |
| Environment Variable values per Environment | none | `frends-env-vars.sh set` | Control Panel |
| Tasks: find, inspect, import | `list_tasks`, `search_task_packages`, `inspect_task`, `import_task` | none | Control Panel Tasks page |
| Tags | none | `frends-tags.sh` | Control Panel |
| Process Templates | none | `frends-templates.sh` | Control Panel |
| API specifications | none | `frends-api-specs.sh` | Control Panel |
| Export for backup or version control | none | `frends-process-pull.sh`, `frends-process-pull.sh --batch` | Control Panel |

MCP tool names are listed without their server prefix.

## Working with the `frends` plugin
Frends' own `frends` plugin owns the MCP workflows. When its skills are listed in the session, hand
the workflow to them and add the companion's part before and after.

| Need | Hand to | Companion adds |
| --- | --- | --- |
| Scope an integration | `frends:integration-planning` | the house standard as an input |
| Choose a Process shape | `frends:process-patterns` | [best-practices.md](best-practices.md) |
| Build or edit one Process | `frends:build-a-process` | [mcp-build-conventions.md](mcp-build-conventions.md) in the brief |
| Build from a confirmed plan | `frends:build-loop`, `frends:deliver-an-integration` | the overlay in the brief |
| Review a draft against its plan | `frends:review-a-draft` | `frends-reviewer` for platform and house rules |
| Find, inspect | `frends:find-and-inspect` | none |
| Diagnose, fix | `frends:diagnose-failures`, `frends:fix-loop` | [debugging.md](debugging.md) for log levels |
| Run | `frends:run-a-process` | none |
| Connection problems | `frends:getting-connected` | none |

The companion keeps:
- house standards and conventions ([best-practices.md](best-practices.md), the overlay);
- the Platform API route and the file route;
- custom Task development ([../tasks/](../tasks/));
- review against platform and house rules (`frends-reviewer`).

Without the `frends` plugin, drive the MCP tools directly: fetch `get_guide('process-authoring')`
before the first builder call and apply the overlay.

## MCP guides own the tool mechanics
The MCP server serves guides through `list_guides` and `get_guide`: `process-authoring`,
`diagnose-process`, `execute-process`, `explore-tasks`, `find-integration`, `manage-environments`,
`search-processes`. Fetch the guide before using its tools. This skill states house rules and the
deltas from those guides; it does not copy them.

## Boundaries
Build work ends at a validated draft. These actions run only on the person's explicit confirmation,
on every route:

| Action | MCP | Platform API |
| --- | --- | --- |
| Promote a draft | `create_process_from_draft` | `frends-process-push.sh` |
| Deploy, activate, deactivate | `deploy_process` | `frends-deploy.sh` |
| Run | `start_process` | `frends-deploy.sh run` |
| Import a Task package | `import_task` | none |
| Create an Environment Variable or set a value | `create_environment_variable` | `frends-env-vars.sh set` |
| Delete or undeploy | none | `frends-deploy.sh undeploy` |

Where the target Environment has "Confirm AI agent actions" enabled, the platform asks the person
itself. Wait for that answer; never call again after a decline.

## Sources
- Tenant MCP guides, `get_guide('process-authoring')`
- Platform API OpenAPI document: `https://<tenant>.frendsapp.com/v1.0/swagger.json`
