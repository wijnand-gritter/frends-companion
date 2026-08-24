# Custom Tasks — index

Authoring your own Frends [Task](../concepts/task.md) when no ready-made one fits and a
[Code Task](../shapes/code-task.md) can't (because it needs libraries Frends doesn't load).

| File | What / when to read |
| --- | --- |
| [authoring.md](authoring.md) | When to build; method signature rules; parameters/UI; result & cancellation; scaffolding; verifying against source. |
| [packaging.md](packaging.md) | NuGet packaging (assembly = package Id), `dotnet pack`, importing into a tenant. |
| [metadata.md](metadata.md) | `FrendsTaskMetadata.json` (which methods are Tasks) and XML-doc help. |

To extend: copy [../_TEMPLATE.md](../_TEMPLATE.md) for a new aspect, add a row above, add a router line
to [../../SKILL.md](../../SKILL.md).
