# Reference syntax (#result, #var, #env, #trigger, #process)

**Baseline:** Frends 6.2

Frends exposes runtime data through `#` references. They work inside Expression fields and inside
Handlebars in Text fields ([handlebars.md](handlebars.md)).

- `#result[Task Name].Field` — the result of a previous shape. The name in brackets is the shape's
  **display name** and may contain spaces, e.g. `#result[HTTP Request].Body`. Available fields
  (`.Body`, `.StatusCode`, ...) depend on the Task's result object.
- `#result` on its own: the result of the shape directly before this one. It depends on the
  order of the diagram, so inserting or moving a shape changes what it reads. Shapes that produce no
  result, such as [Signal Resume](../shapes/signal-resume.md), leave it with nothing to read and the
  Process fails to compile ("Cannot use a #-reference if isn't declared yet, or if there is no
  previous step"). Prefer `#result[Shape name]` wherever the previous shape might change.
- `#var.Name` — a process variable set by an [Assign Variable](../shapes/assign-variable.md) shape
  (or a Code Task).
- `#env.Group.Name` — an [Environment Variable](../concepts/environment-variables.md) (grouped,
  hence two parts).
- `#trigger` — data from the Trigger that started the Process (e.g. an API Trigger's request body).
- `#process` — metadata about the current Process execution.
- `#cert.<name>.<property>` (6.4) — a [managed certificate](../concepts/certificates.md), e.g.
  `#cert.partnerapi.thumbprint`.
- `#source.<path>` (6.4) — the source data, inside a
  [Visual Data Mapper](../shapes/visual-data-mapper.md)'s mappings only.

Use the Process Editor's auto-complete to fill reference and result names; it avoids typos in shape
names.

## Related
[field-types.md](field-types.md) · result objects come from each
[Task](../concepts/task.md)'s definition classes ([task-definition-classes.md](task-definition-classes.md)).
