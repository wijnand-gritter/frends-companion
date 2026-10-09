# Guide: debugging with Process Instances

The [Process Instance](../concepts/process-instance.md) view is the primary debugging surface: each
run, shape by shape, with start time, duration, what executed, and the result.

## Reading Process Instances
- Open **Show Process Instances** from the Process list (or click the Last execution / counts
  columns). Click a shape to inspect its detail.
- Select multiple Processes and use the bulk **Show Process Instances** action to view and filter
  several Processes' executions together — e.g. tracing one Order ID across Processes.
- Filter by time period and state; search promoted result values using SQL wildcards.
- Auto refresh keeps the list near real time; turn it off when reviewing older runs amid heavy
  traffic.
- Via the Platform API: `frends-instances.sh list|details|counts` — see
  [cli_tool_reference.md](cli_tool_reference.md).

## Make runs debuggable in the first place
- **Name shapes meaningfully** — the name is also the `#result[...]` key.
- **Split logic into shapes** instead of one big [Code Task](../shapes/code-task.md); each shape is a
  separately inspectable step.
- **Promote key values** (e.g. an Order ID) so the Instance list is searchable and one business
  entity is traceable across Processes.

## Logging levels and the performance tradeoff
| Level | Records | Use |
| --- | --- | --- |
| Only errors | failed runs only; successful runs leave no Instance detail | production |
| Default | shape results; arrays truncated at 100 elements, text at 10,000 characters | development, test |
| Log everything | parameters and results, no truncation | temporary troubleshooting |

- Set production Agent Groups to **Only errors**. Verbose logging slows Processes and the UI and
  exposes payloads.
- Enable **Log everything** for a set duration so it reverts by itself.
- **Promoted values are logged at every level.** Whatever support needs from a successful
  production run (correlation id, business key, run counts) must be promoted.
- Many promoted values on a high-volume Process can time out the Instance list.
- **"Skip logging result and parameters"** on a shape hides its values from the Instance: use it
  on shapes that carry secrets, personal data or large payloads.

## Source of truth
`https://docs.frends.com/management-and-operations/dashboard-and-monitoring/process-instances.md`
