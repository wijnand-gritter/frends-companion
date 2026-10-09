# Custom Task checklist

Manual review of a custom Task repository. Platform rules come from the Frends Task model;
convention rules from the official template and FrendsTaskSkills, overridden by the house standard.
Detail: `../../frends-ipaas-developer/references/tasks/`.

Report each finding as blocking or non-blocking. Run the commands under "How to check" from the
Task folder. Keep the quotes around `--include` patterns: zsh, the default shell on macOS, stops on
an unquoted `*.cs`. `scripts/review_process.py` reads Process exports only; a Task is reviewed with
this checklist and the commands below.

## Naming and branding

| Id | Rule | Origin | Severity | How to check |
| --- | --- | --- | --- | --- |
| TSK-01 | no `Frends.` party in namespace, assembly, package id or `TaskMethod` | convention | blocker | `grep -rn "Frends\." --include='*.cs' --include='*.csproj' --include='*.json' . \| grep -v FrendsTaskMetadata.json \| grep -v FrendsTaskAnalyzers` |
| TSK-02 | `<Party>.<System>.<Action>`; class = `<System>`, method = `<Action>`; party per house standard | convention | major | read the Task class |
| TSK-03 | csproj `Copyright`, `Product`, `PackageProjectUrl`, `RepositoryUrl` name the owning organisation; a Task without a repository yet leaves the two URLs out rather than keeping the template's | convention | major | read the csproj |
| TSK-04 | the summary's Documentation link, README badges and clone URL point at the owning repository; a relative Documentation link to `README.md` is acceptable until the repository exists | convention | minor | `grep -rn "frends.com\|FrendsPlatform\|app-github-custom-badges" .` |
| TSK-05 | CI does not depend on Frends-internal workflows, feeds or secrets | convention | major | read the pipeline definition |

## Platform rules

| Id | Rule | Origin | Severity | How to check |
| --- | --- | --- | --- | --- |
| TSK-06 | the Task method is `public static`, returns a value, has no overloads; one Task method per project | platform | blocker | read the Task class |
| TSK-07 | `FrendsTaskMetadata.json` lists exactly the Task method, packed to the root, registered as `AdditionalFiles` | platform | blocker | read the file and the csproj |
| TSK-08 | folder, assembly and package id identical | platform | major | compare csproj and folder |
| TSK-09 | target framework `net8.0`, or `net8.0;net10.0` when the Task needs .NET 9 or 10 APIs; no net10.0-only Task while any Agent runs 6.2 | platform | blocker | csproj, tenant versions |

## Contract

| Id | Rule | Origin | Severity | How to check |
| --- | --- | --- | --- | --- |
| TSK-10 | `[PropertyTab]` classes; `Input` first; credentials on `Connection`; no Source or Destination tabs | convention | major | read `Definitions/` |
| TSK-11 | `Options.ThrowErrorOnFailure` (default `true`) and `ErrorMessageOnFailure` | convention | major | read `Options.cs` |
| TSK-12 | Result has `Success` and `Error { Message, AdditionalInfo }`; typed `AdditionalInfo` where the shape is known | convention | major | read `Result.cs`, `Error.cs` |
| TSK-13 | one `try/catch` delegating to `ex.Handle(options)`; `OperationCanceledException` rethrown; the original exception rethrown unchanged, or kept as inner when `ErrorMessageOnFailure` is set | convention | major | read the method and `ErrorHandler.cs` |
| TSK-14 | `CancellationToken` accepted and passed to every async or I/O call | convention | major | read the send path |
| TSK-15 | `ValidationHandler.Run` before any side effect; declarative `[Required]`, `[RequiredIf]` | convention | minor | read the method |
| TSK-16 | no third-party types on parameters or results | convention | major | read `Definitions/` |
| TSK-17 | multi-operation Tasks continue, list every failure, throw at the end | convention | major | read the loop |
| TSK-18 | every template `// TODO:` resolved | convention | minor | `grep -rn "TODO" --include='*.cs' .` (the template also writes `TODO :`) |

## Documentation and versioning

| Id | Rule | Origin | Severity | How to check |
| --- | --- | --- | --- | --- |
| TSK-19 | every public member, parameter and result property documented with `<example>`; extended help in `<frendsdocs>`; no `<cref>` | convention | minor | build warnings, read `Definitions/` |
| TSK-20 | secret properties carry `[PasswordPropertyText]` | convention | blocker | grep `Password`, `Secret`, `Token`, `Key` properties |
| TSK-21 | `<Version>` bumped per release with a CHANGELOG entry written for the Process author | convention | major | compare csproj and CHANGELOG |
| TSK-22 | breaking changes are major versions with a `migration.json` entry and upgrade steps | convention | major | read CHANGELOG and `migration.json` |

## Quality and security

| Id | Rule | Origin | Severity | How to check |
| --- | --- | --- | --- | --- |
| TSK-23 | builds with zero warnings; every suppression explained | convention | major | `dotnet build -warnaserror` |
| TSK-24 | at least 80% coverage; error contract, cancellation and validation tested; offline by default | convention | major | `dotnet test --collect:"XPlat Code Coverage"`, then the `line-rate` in `coverage.cobertura.xml` (`tasks/testing.md`) |
| TSK-25 | no populated `.env` committed; synthetic fixtures; `.gitignore` excludes `.env` (the template ships no `.gitignore`) | convention | blocker | `git ls-files \| grep -E '(^\|/)\.env$'`; outside a Git repository, report the commit check as not assessable and read `.gitignore` |
| TSK-26 | dependency licences MIT, Apache 2.0 or BSD; no known vulnerabilities | convention | major | `dotnet list package --vulnerable --include-transitive` |
| TSK-27 | security checklist passed (`tasks/security.md`) | convention | major | walk the checklist |
