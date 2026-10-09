# Task metadata and documentation

Category: tasks · Baseline: template from `FrendsPlatform/FrendsTasks`, net8.0

What tells Frends which methods are Tasks, how parameters map across versions, and how help reaches
the Process Editor.

## FrendsTaskMetadata.json
Lists the methods exposed as Tasks. Without it every qualifying public static method in the package
becomes a Task.

```json
{ "Tasks": [ { "TaskMethod": "Conclusion.Salesforce.Query.Salesforce.Query" } ] }
```

- `TaskMethod` is `<Namespace>.<Class>.<Method>`; under `<Party>.<System>.<Action>` it reads
  `Party.System.Action.System.Action`.
- The file is next to the csproj and packed to the package root. The template also registers it as
  `AdditionalFiles`, so `FrendsTaskAnalyzers` checks the declared method against the code at build
  time:

```xml
<Content Include="FrendsTaskMetadata.json" Pack="true" PackagePath="/" CopyToOutputDirectory="PreserveNewest" />
<AdditionalFiles Include="FrendsTaskMetadata.json" />
```

- The schema belongs to the platform. If an import rejects the file, take the current shape from the
  template.

## migration.json
Declares how parameters map across Task versions, so Processes move to a new version without manual
reconfiguration. The template seeds it at 1.0.0 and packs it to the package root:

```json
[ { "Task": "Conclusion.Salesforce.Query",
    "Migrations": [ { "Version": "1.0.0", "Description": "", "Migration": [] } ] } ]
```

Add an entry for every release that renames a parameter, moves one between tabs or otherwise breaks
the contract. Take the shape of a migration step from the template and the Frends docs; do not
invent one.

## XML documentation
The Control Panel renders XML documentation into the parameter editor, so it is user interface.

| Rule | Detail |
| --- | --- |
| Coverage | every public member, parameter and result property, each with an `<example>` |
| Summary | short; ends with a Documentation link to the Task README in the owning repository |
| Extended help | in a `<frendsdocs>` tag, never in `<summary>`; long summaries break the editor layout |
| Markdown | supported in `<summary>` and `<frendsdocs>` |
| No `<cref>` | reference tags are not resolved in the rendered help |
| Returns | compact form: `object { bool Success, string Content, object Error { string Message, dynamic AdditionalInfo } }` |
| Lookup | the XML file is packed and named after the package id; parameter-level comments first, then the type |

```csharp
/// <summary>
/// Reads a blob from Azure Blob Storage.
/// [Documentation](https://<repo>/Conclusion.AzureBlob.Read/README.md)
/// </summary>
/// <frendsdocs>
/// Reads a single blob and returns its content as a string. The whole content is held in memory;
/// use a download Task for multi-gigabyte blobs.
/// </frendsdocs>
/// <returns>object { bool Success, string Content, object Error { string Message, dynamic AdditionalInfo } }</returns>
```

## README
Developer setup only: badges for the owning pipeline, certificates, how to run the tests, how to
obtain test credentials (the process, never the credentials), Docker setup, licence attributions.
Parameter descriptions live in the XML documentation. The repository root README links each Task
README.

## Sources
- `FrendsTaskSkills/frends-task-creator/references/documentation-and-metadata.md` (MIT)
- `https://docs.frends.com/reference/tasks/frends-official-task-development-guidelines.md`
