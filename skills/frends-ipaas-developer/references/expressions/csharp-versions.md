# .NET and C# versions

Category: expressions · Baseline: Frends 6.3.2

| Frends | Process compiles against | C# in Code and Expression shapes | Evidence |
| --- | --- | --- | --- |
| 6.3 | .NET 10 | up to C# 14 | release notes 6.3.0; validated on a 6.3.2.5468 tenant: `Enumerable.CountBy` (.NET 9), `JsonSerializerOptions.Strict` (.NET 10), the `\e` escape (C# 13) and null-conditional assignment (C# 14) compile |
| 6.2 | .NET 8 | up to C# 12 | docs |
| older 6.x | .NET 6 | up to C# 10 | docs |
| legacy Agent | .NET Framework 4.7.1, .NET Standard 2.0 | up to C# 7.3 | docs |

- On a 6.3 tenant, .NET 9 and .NET 10 APIs and C# 13 and 14 syntax are available in Code and Expression shapes.
- On a tenant that may still run 6.2, keep to .NET 8 APIs and C# 12.
- Code shapes can `await` directly from 6.3.0. Assign the result to a variable to return a value.
- C# collection expressions (`[]`) compile in Expression shapes from 6.3.1.
- Tasks built for net8.0 compile and run in 6.3 Processes (validated with `Frends.HTTP.Request` 1.13.0 on 6.3.2.5468). See [../tasks/packaging.md](../tasks/packaging.md).

The Process file records `TargetFramework` and `FrendsVersion`; see
[../process-file-format/proprietary-json.md](../process-file-format/proprietary-json.md).

## Source of truth
- `https://docs.frends.com/reference/process-development/c-in-frends.md`
- `https://docs.frends.com/release-notes/frends-6.3/version-6.3.0.md`, `version-6.3.1.md`
