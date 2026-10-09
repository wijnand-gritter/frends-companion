# Custom Tasks: index

Building your own Frends [Task](../concepts/task.md): a C# class library packed as NuGet and
imported into a tenant, used as a Task shape in a Process. Build one only when no catalogue Task
fits and a [Code Task](../shapes/code-task.md) cannot do the work.

| File | What / when to read |
| --- | --- |
| [authoring.md](authoring.md) | When to build; the workflow from template to release; the platform's method rules. Start here. |
| [template.md](template.md) | Installing and running `dotnet new frends-task`, what it generates, de-branding the output. |
| [anatomy.md](anatomy.md) | The contract: signature, tabs, result, error handling, validation, multi-operation Tasks, disposal, layouts per Task type. |
| [metadata.md](metadata.md) | `FrendsTaskMetadata.json`, `migration.json`, XML documentation and `<frendsdocs>`. |
| [packaging.md](packaging.md) | csproj, versioning, changelog, packing, importing into a tenant. |
| [testing.md](testing.md) | Unit tests, coverage, secrets in tests, Docker, CI pipelines. |
| [security.md](security.md) | Security and data-protection checklist for a Task. |
| [house-conventions.md](house-conventions.md) | Where the organisation's own rules differ: party name, repositories, CI, feed. |

Review a Task against these files with the `frends-reviewer` skill's custom Task checklist.

Adapted in part from `FrendsPlatform/FrendsTasks`, folder `FrendsTaskSkills` (MIT licence), and the
`FrendsTaskTemplate` in the same repository.
