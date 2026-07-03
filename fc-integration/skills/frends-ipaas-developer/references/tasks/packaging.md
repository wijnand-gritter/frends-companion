# Custom Task packaging and importing

**Category:** tasks · **Baseline:** Frends 6.2 / net8.0

How to build a custom [Task](authoring.md) into a NuGet package and get it into a tenant. For which
methods become Tasks and how help text is surfaced, see [metadata.md](metadata.md).

## Packaging as NuGet
- Tasks are distributed as NuGet packages (`.nupkg`).
- The **assembly name and package Id must be identical**, e.g. `Frends.TaskTemplate.dll` inside
  `Frends.TaskTemplate.1.0.0.0.nupkg`.
- Pack with `dotnet pack`. For legacy non-SDK projects you may instead need `nuget.exe` with a
  `.nuspec` file.

## Importing into a tenant
Import the `.nupkg` through the **Tasks admin page** in the Control Panel. For automation, use NuGet
feeds so your CI/CD pipeline can publish Task packages and the tenant can pull from the feed (see
[../guides/deployment.md](../guides/deployment.md)). Once imported, the Task appears in the Task
selector for shapes, with your parameters and XML-doc help.

## Source of truth
`https://docs.frends.com/guides/development/creating-custom-tasks.md`;
`github.com/FrendsPlatform/FrendsTaskTemplate`.
