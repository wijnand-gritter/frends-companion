# Control Panel and Tenant

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
Frends is operated through a web-based **Control Panel**, where you design, manage, and monitor
integrations. A customer's installation is a **Tenant** (reached at `https://<tenant>.frendsapp.com`).
Version control and CI/CD-capable deployment are built in.

## Key facts
- The Control Panel is where Processes are authored (Process Editor), deployed, and monitored.
- A Tenant is the unit of installation and isolation; Platform API calls and the Swagger UI live
  under the tenant host (`/swagger`).
- See [environment.md](environment.md) for how a Tenant is divided into promotion stages and
  [agent-and-agent-group.md](agent-and-agent-group.md) for where Processes actually run.

## Source of truth
`https://docs.frends.com/frends-development/centralized-portal/control-panel.md`
