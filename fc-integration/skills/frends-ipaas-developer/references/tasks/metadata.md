# Custom Task metadata and help (FrendsTaskMetadata.json, XML docs)

**Category:** tasks · **Baseline:** Frends 6.2 / net8.0

How to declare which methods are exposed as Tasks and how field/Task help reaches the Process Editor.
For the method itself see [authoring.md](authoring.md); for building/installing see
[packaging.md](packaging.md).

## FrendsTaskMetadata.json
By default every qualifying `public static` method in the package is treated as a Task. To expose
only specific methods, add a `FrendsTaskMetadata.json` at the root of the NuGet package listing them:

```json
{
  "Tasks": [
    { "TaskMethod": "Frends.TaskLibrary.FileActions.DoFileAction" }
  ]
}
```

Only the listed methods become Tasks; other static methods are skipped.

## XML documentation
XML documentation comments surface automatically as field and Task help in the Process Editor:
- Enable XML documentation output in the build (Build / Output / XML documentation file).
- Include the generated XML file in the NuGet package; it must match the package Id (for package Id
  `Frends.TaskLibrary`, the file `Frends.TaskLibrary.xml` is looked up).
- When resolving help, Frends checks the parameter-level documentation first, then the type
  definition.

## Source of truth
`https://docs.frends.com/reference/tasks/frends-official-task-development-guidelines.md`
