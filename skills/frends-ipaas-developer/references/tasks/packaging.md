# Task packaging, versioning and import

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

## csproj after de-branding

```xml
<PropertyGroup>
  <TargetFramework>net8.0</TargetFramework>
  <LangVersion>latest</LangVersion>
  <Version>1.0.0</Version>
  <Authors>Conclusion</Authors>
  <Company>Conclusion</Company>
  <Copyright>Conclusion</Copyright>
  <Product>Conclusion Frends Tasks</Product>
  <PackageTags>Frends;Conclusion</PackageTags>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <Description>Executes a SOQL query against Salesforce.</Description>
  <PackageProjectUrl>https://<repository></PackageProjectUrl>
  <RepositoryUrl>https://<repository></RepositoryUrl>
</PropertyGroup>
```

| Rule | Detail |
| --- | --- |
| Package id | defaults to the assembly name; no `PackageId` override |
| Licence | `PackageLicenseExpression` matches the chosen licence; `PackageLicenseFile` for proprietary |
| Warnings | zero; every `NoWarn` or `#pragma warning disable` carries a comment naming the warning and why muting is safe |
| Packed content | assembly, XML documentation, `FrendsTaskMetadata.json`, `migration.json`, `CHANGELOG.md` |
| Secrets | never a connection string, key or tenant URL in the csproj |
| Target framework | `net8.0`; `<TargetFrameworks>net8.0;net10.0</TargetFrameworks>` only when the Task needs a .NET 9 or 10 API or a dependency drops net8.0 |
| Runtime | Frends 6.3 Processes compile against .NET 10 and Agents run .NET 10; a net8.0 Task compiles and runs in them (validated on 6.3.2.5468 with `Frends.HTTP.Request` 1.13.0, which ships net8.0 only). A net10.0-only Task does not load on 6.2 Agents |
| Tenant export | `TargetFramework` `net10.0` in a 6.3 Process export is the Processes' framework, not a target for the Task: keep the Task on `net8.0` |

## Versioning

| Bump | When |
| --- | --- |
| Major | a parameter moves between tabs or is renamed (typo fixes included); a tab is removed or renamed; a new parameter has no default that keeps the old behaviour |
| Minor | documentation fixes; new parameters whose defaults keep the old behaviour |
| Patch | every test import while iterating: Frends will not import the same version twice (from 6.3.1 the UI blocks it) |

- Every major bump comes with a `migration.json` entry and a CHANGELOG entry with the upgrade steps.
- Prefer a non-breaking design, but never pick a harmful default to avoid a major bump.

## CHANGELOG
Keep a Changelog format, written for the Process author:

```
## [2.0.0] - 2026-10-09
### Changed
- [Breaking] Moved parameter Timeout to the Options tab.
  To upgrade, set the same value on the Options tab as it had on the Input tab.
```

## Pack

```bash
dotnet test Conclusion.Salesforce.Query/Conclusion.Salesforce.Query.sln
dotnet pack Conclusion.Salesforce.Query/Conclusion.Salesforce.Query/Conclusion.Salesforce.Query.csproj -c Release -o out
```

A failing test stops the pack. `out/` is not committed.

Check the package before anyone imports it. The root holds `FrendsTaskMetadata.json`,
`migration.json` and `CHANGELOG.md`; `lib/net8.0/` holds the assembly and the XML documentation
file, both named after the package id:

```bash
unzip -l out/Conclusion.Salesforce.Query.1.0.0.nupkg
```

## Import into a tenant
Importing changes the tenant: only on the person's confirmation.

| Route | How |
| --- | --- |
| MCP | `import_task` pulls a package from the tenant's configured NuGet feeds; the platform asks the person to confirm |
| Control Panel | Tasks page: upload the `.nupkg` |
| Feed | publish to the organisation's NuGet feed from CI; the tenant pulls from it |

The Platform API has no Task import endpoint. Changing a Task's contract affects every Process that
uses it, which is why breaking changes take a major version.

## Sources
- `FrendsTaskSkills/frends-task-creator/references/documentation-and-metadata.md`, `testing-and-cicd.md` (MIT)
- MCP `import_task` tool description, Frends 6.3.2
