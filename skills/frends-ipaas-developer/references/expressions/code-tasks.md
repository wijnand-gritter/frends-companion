# Code Tasks (the C# rules)

**Baseline:** Frends 6.2

> The Code Task **shape** is documented in [../shapes/code-task.md](../shapes/code-task.md). This
> file covers the C# language rules that apply inside it.

A Code Task is the place for more than one expression of C#. A scope is provided; write a
method-like block, optionally with helper functions and lambdas.

- Keep to **one logical action per Code Task**. Don't write the whole Process as one — splitting
  into shapes keeps the flow debuggable in the [Process Instance](../concepts/process-instance.md)
  view.
- To save a value to a variable, the code must `return` (with variable assignment enabled). With
  assignment disabled, do not return a value; behave like a `void` method.
- Assigning to existing variables via `#var` inside code is possible but discouraged for
  readability; prefer the [Assign Variable](../shapes/assign-variable.md) shape.
- **Hard limit:** a Code Task **cannot pull in libraries or namespaces Frends has not already
  loaded.** You cannot add a `using` for a new namespace, nor reference an external library by FQDN.
  `using` is allowed only for resource management (disposing streams). If you need a library Frends
  doesn't load, that is the signal to write a [custom Task](../tasks/authoring.md).

## Related
[namespaces.md](namespaces.md) lists what's available · [csharp-versions.md](csharp-versions.md).
