# Expression best practices

**Baseline:** Frends 6.2

- Keep editor C# to a readable one-liner per Expression field; do heavier work in a
  [Code Task](../shapes/code-task.md) or a [custom Task](../tasks/authoring.md).
- Do any calculation/formatting **before** embedding a value via Handlebars, rather than packing
  logic into the Handlebars expression.
- Prefer explicit shapes ([Assign Variable](../shapes/assign-variable.md),
  [Decision](../shapes/exclusive-decision.md)) over hiding logic inside Code Tasks, so the
  [Process Instance](../concepts/process-instance.md) view stays informative when debugging.
- Name shapes meaningfully — the display name is also how you reference results
  (`#result[Friendly Name]`).

## Related
[field-types.md](field-types.md) · [handlebars.md](handlebars.md) ·
[../guides/debugging.md](../guides/debugging.md).
