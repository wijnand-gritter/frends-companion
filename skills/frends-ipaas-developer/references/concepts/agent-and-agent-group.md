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
- 6.4 drops the Legacy Agent; see below.

## Changed in 6.4
- The Legacy Agent and its installer are gone. A tenant that still has Legacy Agents is not updated
  to 6.4: move its Agent Groups to the Cross-platform Agent first.
- Processes compile for .NET 10 only. A Process version compiled for .NET Framework 4.7.1 can no
  longer be deployed; the next save compiles it for .NET 10.
- On-premises Cross-platform Agents need .NET Runtime 10.0.7 or newer. The Windows Agent installer
  checks for the .NET and ASP.NET Core runtimes first.
- [Certificates](certificates.md) are managed per Agent Group and installed on every Agent in it,
  on Agents of 6.4 or newer.
- The Agent honours `X-Forwarded-Host` and `X-Forwarded-Proto` only from trusted proxies
  (`ForwardedHeaders:KnownProxies`, `ForwardedHeaders:KnownNetworks`), for the URLs it returns for
  OpenAPI and the MCP Trigger. The RFC 7239 `Forwarded` header is no longer read.
- Each Agent Group's RabbitMQ user reads only its own Agent Group's queues.
- Unauthenticated and unmatched HTTP requests are logged at most 10 per minute per endpoint, method
  and status, and 100 per minute in total.

### Self-hosted installations (6.4)
These matter only where your organisation runs the Agents or the Web Portal itself; a Frends
cloud tenant handles them for you.
- Run the database initializer for the ConfigurationStore and LogStore databases. It adds the
  certificate tables and removes the database step-logging tables, and it logs to the console
  only. It can now set up PostgreSQL with fewer privileges.
- log4net is removed. The Log Service reads the `Logging` section of `appsettings.json`
  (`PathFormat`, `RetainedFileCountLimit`, `FileSizeLimitBytes`).
- Agents on Azure Service Bus get their access tokens from the Web Portal with a one-time bootstrap
  key, as from 6.3.3. Coming from 6.3.2 or earlier, download each Agent's configuration or
  Kubernetes files again. RabbitMQ Agents are not affected.
- The unauthenticated request log limits are set with
  `HttpLoggingOptions:UnauthenticatedRequestsPerEndpointPerMinute` and
  `HttpLoggingOptions:UnauthenticatedRequestsPerAgentPerMinute`.
- A `PlatformJwtAllowedIps` entry with only `IpAddress` set used to admit every IPv4 caller. Fixed
  in 6.4.0; check such entries on an older installation.

## Source of truth
`https://docs.frends.com/hybrid-integration-architecture/frends-runtime.md`
