# Reference syntax (#result, #var, #env, #trigger, #process)

**Baseline:** Frends 6.2

Frends exposes runtime data through `#` references. They work inside Expression fields and inside
Handlebars in Text fields ([handlebars.md](handlebars.md)).

- `#result[Task Name].Field` — the result of a previous shape. The name in brackets is the shape's
  **display name** and may contain spaces, e.g. `#result[HTTP Request].Body`. Available fields
  (`.Body`, `.StatusCode`, ...) depend on the Task's result object.
- `#var.Name` — a process variable set by an [Assign Variable](../shapes/assign-variable.md) shape
  (or a Code Task).
- `#env.Group.Name` — an [Environment Variable](../concepts/environment-variables.md) (grouped,
  hence two parts).
- `#trigger` — data from the Trigger that started the Process (e.g. an API Trigger's request body).
- `#process` — metadata about the current Process execution.

Use the Process Editor's auto-complete to fill reference and result names; it avoids typos in shape
names.

## Related
[field-types.md](field-types.md) · result objects come from each
[Task](../concepts/task.md)'s definition classes ([task-definition-classes.md](task-definition-classes.md)).
