# Task testing and CI

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

## Unit tests
The template generates the test project: NUnit 4, `Microsoft.NET.Test.Sdk`, `coverlet.collector`,
`dotenv.net`, StyleCop, and `TestBase.cs`, `FunctionalTests.cs`, `ErrorHandlerTest.cs`.

Coverage is at least 80%. Cover at minimum:

| Case | Expectation |
| --- | --- |
| Happy path | `Success == true`, `Error == null` |
| Failure, `ThrowErrorOnFailure = true` | the original exception type thrown; with `ErrorMessageOnFailure` set, an `Exception` with that message and the original as inner |
| Failure, `ThrowErrorOnFailure = false` | `Success == false`, `Error.Message` set, `ErrorMessageOnFailure` prefixed as `<message>: ` |
| Pre-cancelled `CancellationToken` | `OperationCanceledException` propagates, also with `ThrowErrorOnFailure = false` |
| Missing `[Required]` input | `ValidationException` before any side effect |
| Multi-operation partial failure | remaining operations attempted, every failure in `AdditionalInfo` |
| Deliberate absence of behaviour | a test that fails when the behaviour is added back |

- Extend `TestBase`'s `DefaultInput()`, `DefaultConnection()`, `DefaultOptions()` factories instead of
  building tab objects inline.
- Keep I/O behind a small internal seam so logic is testable without the external system.
- Name tests `Scenario_Condition_Expectation`. The template's own tests use other names; rename them
  as you rewrite them.
- With NUnit 4, `Assert.Throws<T>(() => Task.Method(...))` does not compile (CS0121, ambiguous
  between `TestDelegate` and `Action`) because the Task method returns a value. Cast the lambda as
  the template does: `Assert.Throws<T>((Action)(() => Task.Method(...)))`.
- Run: `dotnet test --collect:"XPlat Code Coverage"`.

### Running on a machine without the .NET 8 runtime
The test project targets net8.0, so `dotnet test` needs the .NET 8 runtime. With only a newer
runtime installed (a machine set up for Frends 6.3 often has .NET 10 only), the test host aborts with
"You must install or update .NET to run this application". Install the .NET 8 runtime, or roll the
run forward without changing the project:

```bash
DOTNET_ROLL_FORWARD=Major dotnet test --collect:"XPlat Code Coverage"
```

Rolling forward is close to production on 6.3, where a net8.0 Task runs on a .NET 10 Agent. CI
still runs on the .NET 8 SDK.

### Reading the coverage
`coverlet.collector` prints no percentage. It writes `coverage.cobertura.xml` under the test
project's `TestResults/<guid>/`, or under the folder `--results-directory` names. From the Task
folder, run the tests into a known folder and read the line rate:

```bash
rm -rf TestResults
dotnet test --collect:"XPlat Code Coverage" --results-directory TestResults
python3 -c "import sys,xml.etree.ElementTree as E; r=E.parse(sys.argv[1]).getroot(); print(f\"line {float(r.get('line-rate')):.1%}\")" \
  "$(find TestResults -name coverage.cobertura.xml | head -1)"
```

The collector has no threshold setting; a CI gate compares the same `line-rate` against 0.80.

## Secrets in tests
- `TestBase` loads `.env` with dotenv; `.env.example` holds placeholders only.
- A populated `.env` is never committed; check `.gitignore` before the first commit.
- Rename the placeholder `FRENDS_SECRET_KEY` to the target system's variable, or remove it.
  `TestBase` throws `InvalidOperationException` when the variable is not set, so every test fails
  until you do. A Task without secrets drops the variable from `TestBase`.
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
