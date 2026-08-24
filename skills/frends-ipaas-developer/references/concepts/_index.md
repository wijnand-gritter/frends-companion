# Concepts — index

The platform model. Read the file that fits; read [process.md](process.md) and
[environment.md](environment.md) first if you're new.

| File | What / when to read |
| --- | --- |
| [control-panel-and-tenant.md](control-panel-and-tenant.md) | Where Frends is operated; what a Tenant is. |
| [process.md](process.md) | The main building block — a BPMN flow. |
| [subprocess.md](subprocess.md) | A reusable Process called from others; deploy-order rule. |
| [task.md](task.md) | The concept of a Task (units of work, NuGet packages). |
| [agent-and-agent-group.md](agent-and-agent-group.md) | What runs Processes and where. |
| [environment.md](environment.md) | Dev/Test/Prod promotion stages. |
| [process-instance.md](process-instance.md) | The record of one execution — the debugging surface. |
| [environment-variables.md](environment-variables.md) | Per-environment config; the deploy-value rule. |
| [api-management.md](api-management.md) | Built-in API management; pairs with the API trigger. |
| [add-on-products.md](add-on-products.md) | BAP and API Portal (documented separately). |

To add a concept: copy [../_TEMPLATE.md](../_TEMPLATE.md) here, add a row above, add a router line to
[../../SKILL.md](../../SKILL.md). See [../../CONTRIBUTING.md](../../CONTRIBUTING.md).
