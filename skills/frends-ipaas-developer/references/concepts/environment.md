# Environment

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
An **Environment** is a stage in the promotion path, typically Development, Test, Production.

## Key facts
- New Processes are created and edited **only in Development**.
- Each Environment contains one or more [Agent Groups](agent-and-agent-group.md).
- Work is promoted by **deploying** from one Environment/Agent Group to the next (see
  [../guides/deployment.md](../guides/deployment.md)).
- [Environment Variables](environment-variables.md) hold per-Environment configuration; every one a
  Process uses must have a value in the **target** Environment or the deploy fails.

## Source of truth
`https://docs.frends.com/management-and-operations/integration-lifecycle/environments.md`
