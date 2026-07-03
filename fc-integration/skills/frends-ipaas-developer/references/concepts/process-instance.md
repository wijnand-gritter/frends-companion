# Process Instance

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
A **Process Instance** is the record of one execution: shape by shape, what happened — start time,
duration, the Task or expression run, the result, and (if extended logging is on) input parameters.
This is the primary debugging surface.

## Key facts
- The Instance list supports filtering by time and state, and searching on promoted values using
  SQL wildcards.
- **Promote key values** (e.g. an Order ID) to make the list searchable and to trace one business
  entity across Processes.
- **Log everything** additionally logs input parameters but carries a performance cost; enable it
  temporarily. See [../guides/debugging.md](../guides/debugging.md).
- Queryable via the Platform API (`/instances/{agentGroupId}`) — see
  [../guides/cli_tool_reference.md](../guides/cli_tool_reference.md).

## Source of truth
`https://docs.frends.com/management-and-operations/dashboard-and-monitoring/process-instances.md`
