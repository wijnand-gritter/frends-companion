# The Frends Task template

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

Always start from the official template. It produces the project layout, tabs, error and validation
handlers, analyzers, tests, CI workflows and metadata; a hand-written skeleton reintroduces what the
template already solves.

## Install (once per machine)
Requires the .NET SDK 8.0 or newer. Version 1.17.0 of the template was installed and run with
SDK 10.0.401.

```bash
dotnet new install frendstasktemplate \
  --nuget-source https://pkgs.dev.azure.com/frends-platform/frends-tasks/_packaging/main/nuget/v3/index.json
dotnet new update            # refresh the template
dotnet new frends-task -h    # options
```

## Generate
Run from the repository root, with the agreed identity. The command writes `.github/workflows/`
into the current directory and the Task folder below it:

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
  .github/workflows/  Query_test_publish.yml  Query_main_release.yml  Query_quick_release.yml
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

The template ships no `.gitignore`. Add one before the first commit that ignores at least `bin/`,
`obj/`, `out/`, `TestResults/` and `.env`.

## De-brand before the first commit
The template is pre-filled for Frends' own repositories. Change these for a custom Task:

| File | Field | Template value | Change to |
| --- | --- | --- | --- |
| csproj | `Copyright` | `Frends` | the owning organisation |
| csproj | `Product` | `Frends` | `<Party> Frends Tasks` |
| csproj | `PackageTags` | `Frends` | `Frends;<Party>` |
| csproj | `PackageProjectUrl` | `https://frends.com/` | the repository or intranet page; remove the element while the Task has no repository |
| csproj | `RepositoryUrl` | `https://github.com/FrendsPlatform/...` | the actual repository; remove the element while the Task has no repository |
| csproj | `PackageLicenseExpression` | `MIT` | the chosen licence, or `PackageLicenseFile` for proprietary |
| Task class | Documentation link in the summary | `https://tasks.frends.com/...` | the Task README in the owning repository; `FrendsTaskAnalyzers` rule FT0012 fails the build without a Markdown `[Documentation]` link, so point it at `README.md` until the repository exists |
| README | badges, clone URL | `FrendsPlatform`, Frends badge service | the owning repository and pipeline, or removed |
| `.github/workflows` | `uses:` reusable workflows, `secrets:` | Frends' workflows and internal feed secrets | the organisation's own pipeline ([testing.md](testing.md)) |

Then resolve what the template leaves to you, marked `// TODO:` in the code:

| File | Template content | Do |
| --- | --- | --- |
| Task class, `Definitions/Connection.cs` | a `Connection` tab with a `ConnectionString` | delete the class and the method parameter when the Task connects to nothing |
| `Definitions/Input.cs`, `Options.cs`, `Result.cs` | the sample `Content`, `Repeat`, `Delimiter` and `Output` | replace with the Task's own parameters; keep `ThrowErrorOnFailure` and `ErrorMessageOnFailure` |
| `Definitions/Error.cs` | `AdditionalInfo` typed as `Exception` | a concrete type where the error shape is known ([anatomy.md](anatomy.md)) |
| `Attributes/RequiredIfAttribute.cs` | the conditional validation attribute | delete it when no property uses `[RequiredIf]` |
| `Tests/TestBase.cs` | reads `FRENDS_SECRET_KEY` and throws when it is not set | rename it to the target system's variable, or remove it; until then every test fails |
| `Tests/ErrorHandlerTest.cs` | provokes a failure with an empty `Input` | use a real invalid input for the Task |

Keep: `TargetFramework net8.0`, `LangVersion latest`, `GenerateDocumentationFile true`, the packing
of `FrendsTaskMetadata.json`, `migration.json` and `CHANGELOG.md`, the `StyleCop.Analyzers` and
`FrendsTaskAnalyzers` references, `ErrorHandler`, `ValidationHandler`, `TestBase` and `.env.example`.
Keep `RequiredIfAttribute` only when a property uses it.

`<Nullable>disable</Nullable>` is the template default, in both csproj files. Enable nullable
reference types before writing code, never halfway through. `ErrorHandler.cs` then needs
`string? customMessage` in its two private helpers to build without warnings.

`FrendsTaskAnalyzers` restores from nuget.org (1.11.0 at the time of writing). If it fails to
restore, check the machine's NuGet sources rather than removing the reference.

## Verify the de-branding

Run from the Task folder. Quote the `--include` patterns: zsh, the default shell on macOS, stops
on an unquoted `*.cs` that matches nothing in the current directory.

```bash
# no Frends party prefix in identifiers
grep -rn "Frends\." --include='*.cs' --include='*.csproj' --include='*.json' . \
  | grep -v FrendsTaskMetadata.json | grep -v FrendsTaskAnalyzers
# leftover branding and dead links
grep -rn "frends.com\|FrendsPlatform\|app-github-custom-badges" .
# unresolved template decisions (the template also writes "TODO :")
grep -rn "TODO" --include='*.cs' .
# clean build, tests pass
dotnet build -warnaserror && dotnet test --collect:"XPlat Code Coverage"
```

`dotnet test` needs the .NET 8 runtime for the net8.0 test project; see [testing.md](testing.md)
when only a newer runtime is installed.

Acceptable matches: `FrendsTaskMetadata.json`, the `FrendsTaskAnalyzers` package reference,
`Frends` in `PackageTags`, prose about the platform.

## Sources
- `https://github.com/FrendsPlatform/FrendsTasks/tree/main/FrendsTaskTemplate`
- `FrendsTaskSkills/frends-task-creator/references/template-output.md` (MIT)
