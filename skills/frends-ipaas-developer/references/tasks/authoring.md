# Custom Task authoring

Category: tasks · Baseline: Frends 6.3 / net8.0

When to build a custom Task, the workflow from template to release, and the rules the platform
enforces on the method.

## When to build one
Build a custom Task only when all three hold:
1. No Task in the catalogue covers the case. Check MCP `search_task_packages` and `list_tasks`, the
   docs at `https://docs.frends.com/tasks/`, and the `FrendsPlatform` GitHub organisation. Forking an
   official Task is often faster than starting from nothing.
2. The logic needs a library or namespace Frends does not load, so a Code Task cannot do it
   ([../expressions/code-tasks.md](../expressions/code-tasks.md),
   [../expressions/namespaces.md](../expressions/namespaces.md)).
3. The logic is reused, or it encodes system behaviour every Process would otherwise re-derive.

Logic that fits the loaded namespaces stays in a Code shape, visible on the canvas.

## Rules the platform enforces
- The Task method is `public static` and returns a value. A `void` method is not discovered.
- No overloads of a Task method name.
- Every method parameter becomes a Task parameter in the Process Editor; a class-typed parameter
  renders as a group of fields, and `[PropertyTab]` renders it as a tab.
- Class hierarchy in parameters stays at two levels or less.
- Frends refuses to import the same package version twice.
- Assembly name and package id are identical; XML documentation is looked up by package id.

## Workflow
1. Agree the identity: `<Party>.<System>.<Action>`. The party is the owning organisation, never
   `Frends` ([house-conventions.md](house-conventions.md)). The action names an operation on an
   entity (`Query`, `UploadObject`, `ListFiles`), never `Process` or `Handle`.
2. Generate from the official template and de-brand the output ([template.md](template.md)).
3. Implement against the contract ([anatomy.md](anatomy.md)); resolve every `// TODO:` the template
   leaves.
4. Document: XML comments with `<example>`, `<frendsdocs>`, `FrendsTaskMetadata.json`,
   `migration.json` ([metadata.md](metadata.md)).
5. Test: at least 80% coverage, the error contract covered, offline by default
   ([testing.md](testing.md)).
6. Secure: run the checklist ([security.md](security.md)).
7. Version, changelog, pack, import ([packaging.md](packaging.md)).
8. Review with the `frends-reviewer` skill's custom Task checklist; report findings as blocking or
   non-blocking.

## Verifying against real source
For exact parameter classes, result fields or attribute usage, read the source of an official Task
(`https://github.com/FrendsPlatform/Frends.<Package>`) or the template
(`https://github.com/FrendsPlatform/FrendsTasks/tree/main/FrendsTaskTemplate`). The standalone
`FrendsPlatform/FrendsTaskTemplate` repository is archived; the template lives in the FrendsTasks
monorepo.

## Debugging an official Task
Clone `https://github.com/FrendsPlatform/Frends.<Package>.git`, run its tests, and reproduce the
issue as a unit test. Routes to a fix: a GitHub issue plus an email to Frends support; a fork with a
pull request; or a custom Task built from the source under the organisation's own party name.

## Sources
- `https://docs.frends.com/tasks/task-guides/creating-custom-tasks.md`
- `https://docs.frends.com/reference/tasks/frends-official-task-development-guidelines.md`
- `FrendsPlatform/FrendsTasks`: `FrendsTaskSkills/frends-task-creator` (MIT), `FrendsTaskTemplate`
