# Node naming rules

**Category:** process-file-format · **Baseline:** Frends 6.3 (confirmed against a production tenant)

## Purpose
The rules a Process's shape names must satisfy for the import parser to accept the file.
Generated exports that repeat a pattern (two error branches, two subprocess calls) hit
these on import, not at generation time.

## Names must be unique across the whole process
Every named flow node - task, code/assign, gateway, call subprocess, scope, event - must
have a name that is unique within the entire process, **including nodes nested inside
scopes and catch subprocesses**. A duplicate fails import with:

```
There was an error while parsing the file (Node name '<name>' already used by another node).
```

Uniqueness is per process, not per container: two shapes in different scopes still
collide.

## What is exempt
- **Sequence flow names**: `yes` / `no` labels repeat freely across gateways.
- **Unnamed shapes**: events, Returns/Throws and catch subprocesses commonly have no
  name; multiple unnamed shapes are fine.

## Observed in public templates
35 of the 77 public templates in `FrendsPlatform/FrendsTemplates` repeat a Return name (for example
`Return and add error to errors variable` four times). They import through the template path. Keep
Return and Throw names unique anyway; the reviewer reports duplicates there as minor and duplicates
on activities, gateways and scopes as blockers.

## Implications for generated processes
- Repeated patterns need per-instance names. A process with two AFAS update branches
  cannot name both error builders "Create AFAS error response"; qualify each with what
  it handles (e.g. "Create organisation error response", "Create sales relation error
  response"). Same for repeated "Call Global Error Handler" shapes and repeated
  "Success?" gateways.
- `#result[Name]` expressions resolve by node name, so name uniqueness is also what
  makes result references unambiguous. When renaming a task, update every
  `#result[...]` that cites it.
- Validate generated files for duplicate names before delivery: collect the `name`
  attribute of every BPMN flow node (excluding `sequenceFlow`) recursively through
  `subProcess` children and reject the file when any name occurs twice.

- From 6.3.1, shape and decision branch names cannot contain a double quote: they broke Process
  compilation and the editor rejects them.

## Related
[../shapes/scope-and-catch.md](../shapes/scope-and-catch.md) ·
[confirmed-shape-parameters.md](confirmed-shape-parameters.md)

## Source of truth
Import-parser behavior confirmed on Frends 6.3. The platform docs do not document the
uniqueness constraint explicitly.
