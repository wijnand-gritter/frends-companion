# Custom Task authoring

**Category:** tasks · **Baseline:** Frends 6.2 / net8.0

How to write the C# of a custom Frends [Task](../concepts/task.md): when to do it, the method rules,
the parameter model, scaffolding, and confirming against real source. For building and installing the
package see [packaging.md](packaging.md); for declaring which methods are Tasks and surfacing help see
[metadata.md](metadata.md).

## When to build a custom Task
Build one when **both** are true: no ready-made Task covers the use case, and the logic needs
libraries or namespaces Frends does not load by default (so a [Code Task](../shapes/code-task.md)
cannot do it — Code Tasks can't add new `using`/libraries). If the logic fits within Frends' loaded
namespaces, prefer a Code Task and keep the work in the visual flow (see
[../expressions/code-tasks.md](../expressions/code-tasks.md) and
[../expressions/namespaces.md](../expressions/namespaces.md)).

## Method signature rules
A Task is a method in a .NET class library. The rules are strict:
- The method must be **`public static`** and **must return a value**. `void` methods cannot be Tasks.
- Methods **cannot be overloaded**. You cannot expose both `CreateFile(string path)` and
  `CreateFile(string path, bool overwrite)` as Tasks.
- **Every parameter of the method becomes a Task parameter** in the Process Editor.
- A class-typed parameter is rendered as a grouped structure of fields in the UI.

A widely used convention (confirm against the current template) groups parameters into classes such
as `Input`, `Options`, and an optional `Connection`, each marked so it renders as its own tab, plus a
`CancellationToken`, returning a `Result` object:

```csharp
public static async Task<Result> MyOperation(
    [PropertyTab] Input input,
    [PropertyTab] Options options,
    CancellationToken cancellationToken)
{
    // ... do the work, honoring cancellationToken ...
    return new Result { Success = true, Data = ... };
}
```

`[PropertyTab]` and `CancellationToken` are template conventions, not hard engine requirements; the
hard requirements are public + static + non-void + no overloads. Pull the template for the exact,
current attribute set.

## Parameters and the UI
Control how parameters appear using attributes from `System.ComponentModel` and
`System.ComponentModel.DataAnnotations`: display names, defaults, password masking, ordering,
conditional visibility, multiline/editor hints, validation. Exact attribute names shift between
versions — read the current template and the "Creating Custom Tasks" doc rather than inventing them. A
class-typed parameter becomes a structured group, which is how the `Input` / `Options` grouping
renders as tabs. These classes are also what a Process author references in C# (see
[../expressions/task-definition-classes.md](../expressions/task-definition-classes.md)).

## Result objects and cancellation
Return a dedicated result class rather than a bare primitive when the Task has more than one output,
so `#result[Task Name].Field` exposes named fields downstream. Honor the `CancellationToken` so the
Agent can cancel long-running executions cleanly.

## Scaffolding with the official template
Frends publishes an official `dotnet new` template, `FrendsTaskTemplate`
(`github.com/FrendsPlatform/FrendsTaskTemplate`). Typical flow:

```bash
# Install the template from the Frends NuGet feed
dotnet new install frendstasktemplate \
  --nuget-source https://pkgs.dev.azure.com/frends-platform/frends-tasks/_packaging/main/nuget/v3/index.json

# Create a new Task project (namespace.class.method form)
dotnet new frends-task -F Frends.ClassName.MethodName -D "Description of the Task"
```

Use any IDE or just the `dotnet` CLI (IDEs generally can't run `dotnet new` templates from their
wizards). The exact template id and flags have varied across versions (older variants used
`dotnet new frendstask --name ... --className ... --taskName ...`) — check the template repo's README
for the current invocation. The Frends Tasks are open source; forking an existing Task from the
`FrendsPlatform` org and adapting it is often faster than starting from scratch.

## Verifying against real Task source
When you need the exact parameter object, result fields, or attribute usage the engine expects, read
the source of an existing Task (or the template) in the `FrendsPlatform` GitHub organization rather
than guessing. This is the authoritative reference for current conventions. See also
[../guides/staying-current.md](../guides/staying-current.md).
