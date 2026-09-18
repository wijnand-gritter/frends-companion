# Exception handler wiring rules for a Scope with a Catch

**Category:** process-file-format · **Baseline:** Frends 6.2 (import-parser behaviour, confirmed by
import on a live tenant and against two editor exports)

## Purpose
The import parser enforces four rules on a Scope whose errors are caught outside it. Breaking any
one of them fails import with the same message, so the message never says which rule was broken:

```
There was an error while parsing the file (An exception handler must return to the same node as the source it's catching from.)
```

Read "return to the same node" as: **the Catch's successor must reach the scope's own target in one
flow.** Rule 3 below is that reading, and it is the rule generated files break.

## The rules

| # | Rule |
|---|---|
| 1 | The `subProcess` has exactly two outgoing flows: one to the Catch, one to the Return |
| 2 | The Catch flow is listed first: `<outgoing>` to the `intermediateCatchEvent`, then `<outgoing>` to the `endEvent` |
| 3 | **The catch branch holds exactly one node, and that node's single outgoing flow targets the same `endEvent` the scope flows to.** More than one shape means wrapping them in a Scope |
| 4 | Nothing branches after the scope. Every decision sits inside a scope, or before the scope |

Rule 3 is counter-intuitive: a chain of `Catch -> Call Subprocess -> Assign -> endEvent` converges
on the right node and still fails, because the parser looks only one hop past the Catch. Two shapes
in the catch branch is the mistake; the fix is a Scope around them, which is exactly what the
editor does.

## The confirmed shape
`examples/scope_catch_export_6.2.json` is an editor export of a process whose catch branch runs a
shared error handler and then decides whether to rethrow. Its whole catch branch is one
`subProcess`:

```
startEvent -> Simulate Hard Error -> subProcess A
subProcess A  <outgoing> -> intermediateCatchEvent     (listed first)
              <outgoing> -> endEvent E
intermediateCatchEvent -> subProcess B
subProcess B -> endEvent E                              (the same E)

inside A: start -> Simulate Failure -> inner end
inside B: start -> [Shared] - Generic error handler -> Hard Error? -> yes: Throw
                                                                   -> no:  inner end
```

The gateway and the Throw live **inside** B, which is how a multi-shape, branching handler satisfies
rules 3 and 4 at once. Element declaration order does not matter; the `<outgoing>` order does.

## What the parser does not require
Confirmed by importing minimal probe processes and by the two exports:

- A Catch may carry a `signalEventDefinition` with **no** paired `intermediateThrowEvent` inside the
  scope. The pairing in [../shapes/scope-and-catch.md](../shapes/scope-and-catch.md) is the editor's
  modelling convention, not an import rule.
- The scope may raise a plain C# exception from a Code Task rather than throwing a signal.
- The one node in the catch branch can be any shape, not only a Scope: a single Code shape or a
  single Call Subprocess flowing straight to the shared end event imports fine.

## Avoiding the construct
A Catch exists to hand an error to a handler. When the handler takes the error as a **parameter**
rather than reading a caught variable, a test or driver process needs no Scope at all: a serialised
exception property bag as a JSON string (`ClassName`, `Message`, `StackTraceString`,
`InnerException`) classifies exactly as a live exception does. Prefer the straight lane when the
throw itself is not what is under test.

## Check it before delivering
These rules are cheap to assert from the generated file and impossible to diagnose from the
importer, so assert them: for every `subProcess` with a Catch among its outgoing flows, check the
count and order of those flows, that the Catch has one outgoing, and that its successor's single
outgoing targets the scope's own `endEvent`.

## Related
[structured-flow-rules.md](structured-flow-rules.md) ·
[../shapes/scope-and-catch.md](../shapes/scope-and-catch.md) ·
[../shapes/throw.md](../shapes/throw.md) ·
[unhandled-error-hook.md](unhandled-error-hook.md) ·
[generation-checklist.md](generation-checklist.md)

## Source of truth
Parser behaviour confirmed on a Frends 6.2 tenant (6.2.3.3649): three minimal probe processes
differing only in the catch wiring, plus `examples/scope_catch_export_6.2.json`, an editor export
that imports. The platform docs do not document these rules.
