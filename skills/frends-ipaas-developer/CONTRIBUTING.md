# Extending the frends-ipaas-developer skill

This skill is organized **by entity**, not by topic, so extending it is mechanical:
one file per shape, trigger, and platform concept, grouped into category folders, with
cross-cutting C# detail factored into `expressions/` and serialization detail into
`process-file-format/`. To add or correct one thing you edit one file (plus, for a new
shape, one line in two index files).

## Directory map

```
SKILL.md                       router only — "read X when Y"
README.md                      what the skill is, for humans
CONTRIBUTING.md                this file
VERSION                        skill version (do not edit casually)
references/
  _TEMPLATE.md                 copy this for any new entity file
  concepts/                    one file per platform entity (Process, Agent, Environment, ...)
  triggers/                    one file per trigger type (+ parameter-fields.md)
  shapes/                      one file per canvas shape (Task, Decision, Loop, ...)
  expressions/                 the cross-cutting C# layer (field types, references, namespaces, ...)
  tasks/                       authoring custom C# Tasks (authoring / packaging / metadata)
  guides/                      cohesive workflow essays (bpmn-modeling, deployment, debugging, ...)
  process-file-format/         the export/import spec, split; examples/ live here
scripts/                       Platform API CLI tools + the Process generator
```

Every category folder has an `_index.md` with a one-line-per-file table. When you add a file to a
folder, add its row to that folder's `_index.md` too (the recipes below remind you).

## How to add a new shape

1. `cp references/_TEMPLATE.md references/shapes/<shape-name>.md` and fill it in.
2. Add the shape's serialization row to `references/process-file-format/shape-type-codes.md`
   (BPMN element + JSON `Type` + `SelectedTypeId`), and a confirmed-parameter snippet to
   `references/process-file-format/confirmed-shape-parameters.md` if you have a real export.
3. Add a row to `references/shapes/_index.md` and one router line under "Shapes" in `SKILL.md`.
4. If the generator should emit it, update `scripts/generate_process.py` and note it in
   `references/guides/cli_tool_reference.md`.

## How to add a new trigger

1. `cp references/_TEMPLATE.md references/triggers/<trigger>.md` and fill it in.
2. Record its `$type`/`config` shape in `references/process-file-format/triggers-encoding.md`
   (confirm against a real export — several trigger configs are still inferred).
3. Add a row to `references/triggers/_index.md` and one router line under "Triggers" in `SKILL.md`.

## How to add a platform concept

1. `cp references/_TEMPLATE.md references/concepts/<concept>.md`.
2. Add a row to `references/concepts/_index.md` and one router line under "Concepts" in `SKILL.md`.

## How to add a custom-Task aspect

Custom Task authoring lives in `references/tasks/` (`authoring.md`, `packaging.md`, `metadata.md`).
Add a new aspect file there, add a row to `references/tasks/_index.md`, and link it from the relevant
existing file and `SKILL.md`.

## How to add a guide

Guides are whole essays, not per-entity. Drop `references/guides/<guide>.md` and link it from
`SKILL.md`. Keep entity-specific detail in the entity files and link to them from the guide.

## Conventions

- **One entity per file**; keep the `_TEMPLATE.md` section headings.
- **Link, don't duplicate.** Field-type rules live in `expressions/field-types.md`; reference
  them. Serialization lives in `process-file-format/`; reference it.
- **Relative links** between reference files (e.g. `../expressions/namespaces.md`) so they
  resolve wherever the skill is installed.
- State the version baseline (6.2 or 6.3) and the evidence label of each claim:
  confirmed (export, import, MCP schema, OpenAPI), docs, corpus or inferred
  ([references/guides/staying-current.md](references/guides/staying-current.md)).
- **Never invent version-sensitive specifics** (exact Task parameter names, enum members, trigger
  `config` shapes). Link to the source of truth and say it must be confirmed.
- Bump `VERSION` (minor) when you add or materially change entity coverage; update `SKILL.md`'s
  router in the same change so nothing is unreachable.
