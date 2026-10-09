# Task anatomy: the contract

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

Tab layout, result shape and error handling are contracts: Process authors rely on every Task
behaving the same way.

## Signature
One public static method per Task project; everything else in the assembly is `internal`.

```csharp
namespace Conclusion.Salesforce.Query;

/// <summary>Task class for Salesforce operations.</summary>
public static class Salesforce
{
    /// <summary>
    /// Executes a SOQL query against Salesforce.
    /// [Documentation](https://<repo>/Conclusion.Salesforce.Query/README.md)
    /// </summary>
    /// <param name="input">Essential parameters.</param>
    /// <param name="connection">Connection parameters.</param>
    /// <param name="options">Additional parameters.</param>
    /// <param name="cancellationToken">A cancellation token provided by Frends Platform.</param>
    /// <returns>object { bool Success, dynamic Data, object Error { string Message, dynamic AdditionalInfo } }</returns>
    public static async Task<Result> Query(
        [PropertyTab] Input input,
        [PropertyTab] Connection connection,
        [PropertyTab] Options options,
        CancellationToken cancellationToken)
    {
        try
        {
            ValidationHandler.Run(input, connection, options);
            cancellationToken.ThrowIfCancellationRequested();
            // work; pass cancellationToken to every awaited call
            return new Result { Success = true, Data = data, Error = null };
        }
        catch (Exception ex)
        {
            return ex.Handle(options);
        }
    }
}
```

| Element | Rule |
| --- | --- |
| Class | `public static class <System>` |
| Method | `<Action>`; async `Task<Result>` for I/O; never `.Result` or `.Wait()` |
| `CancellationToken` | last parameter, never decorated, passed to every awaited call and checked in long loops |
| `[PropertyTab]` | `System.ComponentModel.PropertyTabAttribute`; no Frends NuGet dependency needed |
| Validation | `ValidationHandler.Run(...)` first, so bad input fails before any side effect |

## Tabs

| Tab | Holds | Rule |
| --- | --- | --- |
| `Input` | parameters essential to the function | always present, always first |
| `Connection` | URLs, tokens, client ids and secrets, connection strings | database connection strings always here; delete the class when the Task connects to nothing |
| `Options` | optional behaviour | always `ThrowErrorOnFailure` (default `true`) and `ErrorMessageOnFailure`; never connection parameters |

No Source or Destination tabs: their connection parameters go to `Connection`.

```csharp
public class Options
{
    /// <summary>Whether an exception is thrown when the Task fails. When false, the failure is reported in the Result.</summary>
    /// <example>true</example>
    [DefaultValue(true)]
    public bool ThrowErrorOnFailure { get; set; } = true;

    /// <summary>Message used instead of the default error message when the Task fails.</summary>
    /// <example>Failed to query Salesforce accounts</example>
    [DisplayFormat(DataFormatString = "Text")]
    [DefaultValue("")]
    public string ErrorMessageOnFailure { get; set; } = string.Empty;
}
```

## Parameter attributes (`System.ComponentModel`, `System.ComponentModel.DataAnnotations`)

| Attribute | Effect |
| --- | --- |
| `[DefaultValue(...)]` | pre-filled value; the value is an expression (`true`, `"\"C:\\Temp\""`) |
| `[PasswordPropertyText]` | masks the value in the editor and logs it as `<< Secret >>`; mandatory for secrets |
| `[DisplayFormat(DataFormatString = "Text")]` | literal text instead of a C# expression |
| `[DisplayFormat(DataFormatString = "Json" \| "Xml" \| "Sql" \| "Expression")]` | editor type |
| `[UIHint(nameof(Other), "", value...)]` | shows the field only when `Other` has one of the values |
| `[Required]`, `[Range]`, `[RequiredIf]` | validation run by `ValidationHandler`; also drives the editor |

## Parameter naming
- PascalCase, descriptive, short; whole words (`Arguments`, never `Args`).
- Abbreviations only where common, PascalCased: `Csv`, `Url`, `Xml`, `Api`.
- Disambiguate: `InputFilePath` and `OutputFilePath`, never a bare `FilePath`.
- No system name in a parameter name: in `Conclusion.Salesforce.Query`, `SalesforceQuery` is redundant.
- Descriptions say what the parameter does; examples welcome.

## Result

```csharp
public class Result
{
    /// <summary>Whether the Task completed successfully.</summary>
    /// <example>true</example>
    public bool Success { get; set; }

    /// <summary>Rows returned by the query.</summary>
    /// <example>[{"Id":"001","Name":"Example Oy"}]</example>
    public dynamic Data { get; set; }

    /// <summary>Error details when Success is false; null otherwise.</summary>
    public Error Error { get; set; }
}

public class Error
{
    /// <summary>Human-readable error message.</summary>
    public string Message { get; set; }

    /// <summary>Structured details about what went wrong.</summary>
    public dynamic AdditionalInfo { get; set; }
}
```

The template generates `AdditionalInfo` as `Exception`. Keep that when the Task has no richer error
shape; otherwise replace it with a concrete type.

| Rule | Detail |
| --- | --- |
| Always `Success` and `Error` | `Error { Message, AdditionalInfo }` |
| Payload name | `Data` for weakly defined data; a semantic name for a known shape: `Content`, `FilePaths`, `StatusCode`, `Body` |
| Undefined shapes | `dynamic` holding a Newtonsoft `JToken`, as Processes expect for JSON |
| `AdditionalInfo` | a concrete type where the shape is known (identifiers, status codes, failed items); the exception itself when nothing better exists |
| No third-party types | parameters and results never expose SDK classes; map to own DTOs (the Agent deserialises across an assembly load context boundary) |
| No secrets or personal data | never in `Message` or `AdditionalInfo`: they surface in Process Instance logs |

## Error handling
One `try/catch` around the body, delegating to the template's `ex.Handle(options)`:

| Behaviour | Reason |
| --- | --- |
| `OperationCanceledException` is rethrown first | a stopped Process is a normal stop, never `Success = false` |
| `ThrowErrorOnFailure = true`, `ErrorMessageOnFailure` empty: the original exception is rethrown unchanged | `ExceptionDispatchInfo` keeps its type and stack trace in the Process Instance |
| `ThrowErrorOnFailure = true`, `ErrorMessageOnFailure` set: a new `Exception` with that message and the original as inner | the Process author's message leads, the cause survives |
| `ThrowErrorOnFailure = false` returns `Success = false` | `Error.Message` is `<ErrorMessageOnFailure>: <original message>`, or the original message alone; `AdditionalInfo` holds the exception |
| A raw exception never escapes when `ThrowErrorOnFailure` is false | the Process chose to branch on the result |

Richer error detail goes into a typed `AdditionalInfo`, never into a changed handler flow. The older
`ErrorHandler.Handle(ex, throwOnFailure, message)` in the guidelines PDF is superseded by the
template's extension method.

## Multi-operation Tasks
1. Continue after one failed operation where that is logically sound.
2. Set `Success = false` and list every failed operation in `AdditionalInfo`.
3. With `ThrowErrorOnFailure = true`, finish the remaining operations, then throw.

## Disposal
Resources that cannot be released per execution (pools, native handles, listeners) are released on
assembly load context unload, so the Agent does not leak them between Task versions:

```csharp
static Salesforce()
{
    var context = AssemblyLoadContext.GetLoadContext(Assembly.GetExecutingAssembly());
    if (context != null) context.Unloading += OnUnloading;
}

private static void OnUnloading(AssemblyLoadContext context)
{
    // dispose resources
    context.Unloading -= OnUnloading;
}
```

Use it only where `using` blocks per execution cannot do the job. Reuse `HttpClient` (static or a
factory); never one per call in a loop.

## Layouts per Task type

| Type | Input | Connection | Result |
| --- | --- | --- | --- |
| Database | `Query`, then `Parameters` (always parameterised) | connection string | `Data`, plus `RecordsAffected` when the database reports it; Options carry isolation level and command timeout |
| REST API | `Method`, `Url` or `Domain`, `ApiVersion`, `Message` | credentials | `Body`, `StatusCode`; allow-list the host unless the Task is a general HTTP client |
| Converter | named for the source type (`Json`) | none | named for the target type (`Xml`); DTD and external entities disabled |
| File | local paths first, then remote; `ActionOnExistingFile` on Input; full paths (`InputFilePath`) | server details | read: `Content`; write, move, upload: `FilePath(s)` or `Url`; list, delete: `FileName(s)`; paths canonicalised against traversal |

## Sources
- `FrendsTaskSkills/frends-task-creator/references/task-anatomy.md` (MIT)
- `FrendsTaskTemplate/Frends.Template/Party.Echo.Execute`
- `https://docs.frends.com/tasks/task-guides/creating-custom-tasks.md`
