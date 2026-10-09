# The Frends Task template

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

Always start from the official template. It produces the project layout, tabs, error and validation
handlers, analyzers, tests, CI workflows and metadata; a hand-written skeleton reintroduces what the
template already solves.

## Install (once per machine)
Requires the .NET SDK 8.0 or newer.

```bash
dotnet new install frendstasktemplate \
  --nuget-source https://pkgs.dev.azure.com/frends-platform/frends-tasks/_packaging/main/nuget/v3/index.json
dotnet new update            # refresh the template
dotnet new frends-task -h    # options
```

## Generate
Run from the repository root, with the agreed identity:

```bash
dotnet new frends-task -F Conclusion.Salesforce.Query -D "Executes a SOQL query against Salesforce."
```

| Placeholder | Comes from | Example |
| --- | --- | --- |
| `Party` | first segment of `-F` | `Conclusion` |
| `Echo` (class) | second segment | `Salesforce` |
| `Execute` (method) | third segment | `Query` |
| `TaskDescription` | `-D` | `Executes a SOQL query against Salesforce.` |

Never accept the default `-F Frends.Echo.Execute`: the `Frends.` party is reserved for the official
catalogue. PascalCase throughout, abbreviations included: `Csv`, `Url`, `Api`.

## What it generates

```
repo-root/
  .github/workflows/  Query_test_on_push.yml  Query_test_on_main.yml  Query_release.yml
  Conclusion.Salesforce.Query/
    README.md  CHANGELOG.md  Conclusion.Salesforce.Query.sln
    Conclusion.Salesforce.Query/
      Conclusion.Salesforce.Query.cs   the Task class and method
      Conclusion.Salesforce.Query.csproj
      FrendsTaskMetadata.json  migration.json  GlobalSuppressions.cs
      Definitions/  Input.cs  Connection.cs  Options.cs  Result.cs  Error.cs
      Helpers/      ErrorHandler.cs  ValidationHandler.cs
      Attributes/   RequiredIfAttribute.cs
    Conclusion.Salesforce.Query.Tests/
      Conclusion.Salesforce.Query.Tests.csproj
      TestBase.cs  FunctionalTests.cs  ErrorHandlerTest.cs  GlobalSuppressions.cs  .env.example
```

One folder and one solution per Task. Tasks are released independently; code is never shared
between Task projects.

## De-brand before the first commit
The template is pre-filled for Frends' own repositories. Change these for a custom Task:

| File | Field | Template value | Change to |
| --- | --- | --- | --- |
| csproj | `Copyright` | `Frends` | the owning organisation |
| csproj | `Product` | `Frends` | `<Party> Frends Tasks` |
| csproj | `PackageTags` | `Frends` | `Frends;<Party>` |
| csproj | `PackageProjectUrl` | `https://frends.com/` | the repository or intranet page |
| csproj | `RepositoryUrl` | `https://github.com/FrendsPlatform/...` | the actual repository |
| csproj | `PackageLicenseExpression` | `MIT` | the chosen licence, or `PackageLicenseFile` for proprietary |
| Task class | Documentation link in the summary | `https://tasks.frends.com/...` | the Task README in the owning repository |
| README | badges, clone URL | `FrendsPlatform`, Frends badge service | the owning repository and pipeline, or removed |
| `.github/workflows` | `uses:` reusable workflows, `secrets:` | Frends' workflows and internal feed secrets | the organisation's own pipeline ([testing.md](testing.md)) |

Keep: `TargetFramework net8.0`, `LangVersion latest`, `GenerateDocumentationFile true`, the packing
of `FrendsTaskMetadata.json`, `migration.json` and `CHANGELOG.md`, the `StyleCop.Analyzers` and
`FrendsTaskAnalyzers` references, `ErrorHandler`, `ValidationHandler`, `RequiredIfAttribute`,
`TestBase` and `.env.example`.

`<Nullable>disable</Nullable>` is the template default. Enable nullable reference types before
writing code, never halfway through.

If `FrendsTaskAnalyzers` fails to restore, it comes from the same Azure DevOps feed as the template:
add that feed to `nuget.config` rather than removing the reference.

## Verify the de-branding

```bash
# no Frends party prefix in identifiers
grep -rn "Frends\." --include=*.cs --include=*.csproj --include=*.json . \
  | grep -v FrendsTaskMetadata.json | grep -v FrendsTaskAnalyzers
# leftover branding and dead links
grep -rn "frends.com\|FrendsPlatform\|app-github-custom-badges" .
# unresolved template decisions
grep -rn "TODO:" --include=*.cs .
# clean build, tests pass
dotnet build -warnaserror && dotnet test --collect:"XPlat Code Coverage"
```

Acceptable matches: `FrendsTaskMetadata.json`, the `FrendsTaskAnalyzers` package reference,
`Frends` in `PackageTags`, prose about the platform.

## Sources
- `https://github.com/FrendsPlatform/FrendsTasks/tree/main/FrendsTaskTemplate`
- `FrendsTaskSkills/frends-task-creator/references/template-output.md` (MIT)
