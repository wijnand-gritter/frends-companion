# Guide: deployment

How work moves from Development to Production, and the prerequisites that block deployments. For
reading executions afterward, see [debugging.md](debugging.md).

## Environments and the promotion path
A Tenant has multiple [Environments](../concepts/environment.md), typically Development, Test,
Production. Each contains one or more [Agent Groups](../concepts/agent-and-agent-group.md), and the
Agents in a group execute the Processes deployed there. New Processes and edits happen **only in
Development**; you promote to other Environments by **deploying**.

## Versioning
Editing a Process creates a **new version** each save, but only in Development. Other Environments do
not change until you deploy a version to them. While editing, the button is "Save changes"; to save
work that is not yet valid, use "Create new draft" (saves without creating a usable version). Always
add a short version comment.

## Deployment prerequisites (the two that bite)
Both must be satisfied or the deploy fails:
1. **Subprocesses first.** Any [Subprocess](../concepts/subprocess.md) the Process uses must already
   be deployed to the target Agent Group/Environment.
2. **Environment Variable values.** Every [Environment Variable](../concepts/environment-variables.md)
   referenced must already have a value in the **target** Environment — the most common deploy error.

Also infrastructure: from Frends 6.3, on-premise Cross-platform Agents require
**.NET Runtime 10.0.5 or newer** - an outdated runtime blocks the Agent, not just one deploy.

## How to deploy
1. In the Process list, select the Environment and Agent Group holding the version. To deploy the
   very latest, deploy from the Development Agent Group.
2. Open the Process's actions and choose **Deploy Process to Agent Group**.
3. Pick the target Agent Group (which determines the target Environment).
4. Choose the version to deploy.
5. Deploy.

Via the Platform API, this is `frends-deploy.sh deploy` — see
[cli_tool_reference.md](cli_tool_reference.md).

## Activating Triggers
- **Deploy and activate Triggers** — the automated start conditions (schedule, file, API) become live
  immediately.
- **Deploy** — leaves the active/inactive Trigger state in the target unchanged.
Manual execution works regardless of Trigger activation state.

## Running a Process manually
Use **Run once** to execute via the [Manual Trigger](../triggers/manual.md). An Agent must exist in
the selected Agent Group. If the Manual Trigger defines parameters you are prompted for them. A
Process expecting [API Trigger](../triggers/api.md) values will likely fail under Run once.

## CI/CD
Version control and CI/CD-capable deployment are built in. For custom Tasks, publish NuGet packages
from your pipeline to a feed the tenant consumes
([custom Task packaging](../tasks/packaging.md)). For Processes, the Development → Test →
Production promotion model is the spine of a controlled release flow; for pipeline-level specifics
fetch the live docs.

## Source of truth
`https://docs.frends.com/guides/integration-management/deploying-integrations.md`
