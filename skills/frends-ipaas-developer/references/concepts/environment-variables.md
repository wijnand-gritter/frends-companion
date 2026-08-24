# Environment Variables

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
**Environment Variables** hold per-[Environment](environment.md) configuration (URLs, credentials,
paths). They are referenced in C# as `#env.Group.Name` — grouped, hence the two-part name.

## Key facts
- **Critical deployment rule:** every Environment Variable a Process uses must already have a value
  defined in the **target** Environment, or the deployment fails. This is the most common deploy
  error (see [../guides/deployment.md](../guides/deployment.md)).
- Reference them with `#env.Group.Name` in Expression fields, or `{{#env.Group.Name}}` in Text
  fields (see [../expressions/reference-syntax.md](../expressions/reference-syntax.md)). Secrets
  belong here, never inlined into a Process.
- Types include String, Number, Boolean, Array, Object, and Secret.
- Managed via the Platform API `/environment-variables` endpoints (see
  [../guides/cli_tool_reference.md](../guides/cli_tool_reference.md)).

## Source of truth
`https://docs.frends.com/management-and-operations/integration-lifecycle/environment-variables.md`
