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
By default, input parameters are not shown in the Instance. Enabling **Log everything** (in Log
settings, at the Process or Agent Group level) additionally logs and displays input parameters —
invaluable when debugging but with a performance cost. Use it temporarily; Log settings allow
enabling it for a set duration so it reverts automatically.

## Source of truth
`https://docs.frends.com/management-and-operations/dashboard-and-monitoring/process-instances.md`
