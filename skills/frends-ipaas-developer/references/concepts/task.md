# Task (concept)

**Category:** concept · **Baseline:** Frends 6.2

> This is the platform concept of a Task. For the **Task shape** on the canvas see
> [../shapes/task.md](../shapes/task.md); for authoring your own see
> [../tasks/authoring.md](../tasks/authoring.md).

## Purpose
A **Task** is a unit of work: a specific operation such as an HTTP request, a SQL query, a file
read, or a data transform. Frends calls these Tasks rather than "connectors".

## Key facts
- Tasks are .NET/C# components, distributed and imported as **NuGet packages**.
- Frends ships 250+ ready-made Tasks, which are **open source** (the `FrendsPlatform` GitHub org).
- Tasks are highly configurable and reusable; parameters are set in the right sidebar of the
  Process Editor after selecting the Task type for a shape.
- Each Task brings its own definition classes usable in C#, e.g.
  `Frends.HTTP.Request.Definitions.Header` (see
  [../expressions/task-definition-classes.md](../expressions/task-definition-classes.md)). Confirm
  exact parameter objects from the Task tooltips, the Task docs, or the source on GitHub.
- When no ready-made Task fits and the logic needs libraries Frends does not load by default,
  author a custom Task.

## Source of truth
`https://docs.frends.com/frends-development/integrations/connectors.md`; Task source on the
`FrendsPlatform` GitHub organization.
