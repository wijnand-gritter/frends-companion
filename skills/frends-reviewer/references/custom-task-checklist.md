# Custom Task checklist

Manual review of a custom Task repository. Platform rules come from the Frends Task model;
convention rules from the FrendsPlatform Task template and the Frends best practices collection.
Detail: `../../frends-ipaas-developer/references/tasks/`.

| Id | Rule | Origin | Severity | How to check |
| --- | --- | --- | --- | --- |
| TSK-01 | no Frends catalogue Task already covers the case | convention | major | search the catalogue and FrendsPlatform GitHub |
| TSK-02 | the logic needs a library or namespace a Code Task cannot load | convention | minor | read the `using` list |
| TSK-03 | the Task method is `public static`, returns a value, has no overloads | platform | blocker | read the entry class |
| TSK-04 | `FrendsTaskMetadata.json` lists exactly the Task methods and is packed to the root | platform | blocker | read the file and the `.csproj` |
| TSK-05 | folder, assembly and package id are identical | platform | major | compare `.csproj` and folder |
| TSK-06 | parameter classes `Input`, `Connection`, `Options` with `[PropertyTab]`; a result class | convention | minor | read `Definitions/` |
| TSK-07 | `Result` properties are `{ get; internal set; }` | convention | minor | read `Result.cs` |
| TSK-08 | `Options.ThrowExceptionOnErrorResponse` where the call can fail at run time | convention | major | read `Options.cs` |
| TSK-09 | the error object has typed fields, the raw body kept separately | convention | minor | read `Error.cs` |
| TSK-10 | secret properties carry `[PasswordPropertyText(true)]` | convention | blocker | grep `Password`, `Secret`, `Token`, `Key` properties |
| TSK-11 | every public member has an XML doc comment; `GenerateDocumentationFile` on | convention | minor | build warnings, `.csproj` |
| TSK-12 | `CancellationToken` honoured; timeout and cancellation kept apart | convention | minor | read the send path |
| TSK-13 | a test project exists and runs offline | convention | major | `dotnet test`; no real endpoints |
| TSK-14 | static test seams reset in `[SetUp]` and `[TearDown]` | convention | minor | read the test class |
| TSK-15 | `<Version>` bumped with a changelog entry per release | convention | major | compare `.csproj` and `CHANGELOG.md` |
| TSK-16 | target framework matches the Agent (`net8.0` for 6.2) | platform | blocker | `.csproj` |
