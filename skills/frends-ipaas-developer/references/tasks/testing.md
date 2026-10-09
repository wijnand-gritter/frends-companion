# Task testing and CI

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

## Unit tests
The template generates the test project: NUnit 4, `Microsoft.NET.Test.Sdk`, `coverlet.collector`,
`dotenv.net`, StyleCop, and `TestBase.cs`, `FunctionalTests.cs`, `ErrorHandlerTest.cs`.

Coverage is at least 80%. Cover at minimum:

| Case | Expectation |
| --- | --- |
| Happy path | `Success == true`, `Error == null` |
| Failure, `ThrowErrorOnFailure = true` | exception thrown, original exception as inner |
| Failure, `ThrowErrorOnFailure = false` | `Success == false`, `Error.Message` set, `ErrorMessageOnFailure` prefixed |
| Pre-cancelled `CancellationToken` | `OperationCanceledException` propagates |
| Missing `[Required]` input | `ValidationException` before any side effect |
| Multi-operation partial failure | remaining operations attempted, every failure in `AdditionalInfo` |
| Deliberate absence of behaviour | a test that fails when the behaviour is added back |

- Extend `TestBase`'s `DefaultInput()`, `DefaultConnection()`, `DefaultOptions()` factories instead of
  building tab objects inline.
- Keep I/O behind a small internal seam so logic is testable without the external system.
- Name tests `Scenario_Condition_Expectation`.
- Run: `dotnet test --collect:"XPlat Code Coverage"`.

## Secrets in tests
- `TestBase` loads `.env` with dotenv; `.env.example` holds placeholders only.
- A populated `.env` is never committed; check `.gitignore` before the first commit.
- Rename the placeholder `FRENDS_SECRET_KEY` to the target system's variable, or remove it.
- CI injects secrets as pipeline variables; never in logs, issues or chat.
- Fixtures are synthetic or anonymised; never production personal data.

## Real systems
- Where the target has a container image (databases, brokers, S3-compatible stores), test against it
  with a `docker-compose.yml`, documented in the README.
- Otherwise mock the service in the test project; where that is unrealistic, document how to get a
  test account.

## CI
The template ships GitHub workflows that call `FrendsPlatform/FrendsTasks` reusable workflows with
Frends-internal secrets. A custom Task repository replaces them with its own pipeline
([house-conventions.md](house-conventions.md)) that:

| Stage | Content |
| --- | --- |
| Test, every push | `dotnet build -warnaserror`, `dotnet test` with coverage, coverage gate at 80% |
| Pack, main or tag | `dotnet pack -c Release` |
| Publish, tag | push the `.nupkg` to the organisation's NuGet feed |
| Guard | no publish without a bumped `<Version>` and a CHANGELOG entry |

Keep in any pipeline: .NET 8 SDK, strict analyzers, a path filter per Task folder, least-privilege
permissions. When reusing someone else's workflows, pin them to a commit SHA, never `@main`.

## Dependencies
- Permitted licences: MIT, Apache 2.0, BSD. GPL, AGPL, LGPL and anything unverified are not used.
- Attribution required by a licence goes in the Task README.
- `dotnet list package --vulnerable --include-transitive` is clean, or findings are documented.
- Keep the dependency surface small; pin one version of a package across the Tasks in a repository.

## Sources
- `FrendsTaskSkills/frends-task-creator/references/testing-and-cicd.md` (MIT)
