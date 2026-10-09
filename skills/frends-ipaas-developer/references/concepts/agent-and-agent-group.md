# Agent and Agent Group

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
An **Agent** is the runtime executable that actually runs Processes — on a server, on-premises, in
the cloud, or close to the data it needs. Agents are organized into **Agent Groups**.

## Key facts
- A Process is deployed to an **Agent Group**; the Agents in that group execute it.
- Frends ships at minimum a Development [Environment](environment.md) with a Cloud Agent, so light
  testing needs no own hardware; anything beyond light testing should run on your own Agent.
- This central-management / distributed-execution split is core to Frends as a hybrid iPaaS.
- An Agent Group belongs to exactly one Environment and has a framework flag (`isCrossPlatform`);
  the Process target framework must match it to deploy.
- Agent Group IDs are needed for deploys and for listing [Process Instances](process-instance.md)
  via the Platform API (see [../guides/cli_tool_reference.md](../guides/cli_tool_reference.md)).

## Changed in 6.3
- **Agent Registration Mode** replaces the old toggle: an Agent Group is explicitly one of
  Self-Hosted Agent, Cloud Agent, Kubernetes Deployment, or Kubernetes StatefulSet.
- On-premise **Cross-platform Agents require .NET Runtime 10.0.5 or newer** from 6.3 onwards, and
  10.0.7 or newer from 6.3.1. The Windows Agent and the Management Web Portal need the .NET 10
  hosting bundle. Cloud Agents include .NET 10.
- Legacy Agent Groups can no longer be created.
- Process execution tracing and metrics can be exported to OpenTelemetry.
- Remote Subprocess execution is re-architected (Agent-specific sessions with batching) for
  high parallel loads - a behaviour-neutral performance change.
- Heads-up: **6.4 drops the Legacy Agent** entirely; plan migrations to the Cross-platform
  Agent before upgrading past 6.3.

## Source of truth
`https://docs.frends.com/hybrid-integration-architecture/frends-runtime.md`
