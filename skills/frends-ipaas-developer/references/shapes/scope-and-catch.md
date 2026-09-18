# Scope and Catch shapes

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
A **Scope** groups shapes for resource and error management (and is the container behind
[loops](loop.md)). A **Catch** entry catches errors/signals thrown within a scope. Together they
implement Frends' standard error-handling pattern.

## Fields / configuration
A Scope contains its own start node and body. A Catch is wired to a `signalEventDefinition` matching
a [Throw](throw.md) inside the scope, and typically routes to a shared error-handler
[Subprocess](../concepts/subprocess.md) via [Call Subprocess](call-subprocess.md). The Throw pairing
is the editor's modelling convention: the importer accepts a Catch with no paired Throw, and a scope
that raises a plain C# exception.

## Serialization
A **Scope** is a BPMN `subProcess` (`isExpanded="true"`, contains its own flow); JSON `Type` **8**
(confirmed 6.2). [Foreach](loop.md) and [While](loop.md) are the same `subProcess` element with
`Type` **10** and **11**. Every embedded scope's start node is `Type` **13**. A **Catch** is a BPMN
`intermediateCatchEvent`; JSON `Type` **14**, with a plain-string `expression` parameter naming the
error variable (e.g. `{ "expression": "error" }`). See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Import rules when generating a file
Four rules the import parser enforces, all reporting the same message. The one that catches
generators out: **the catch branch holds exactly one node**, whose single outgoing flow goes to the
same end event the scope flows to. Two shapes in the catch branch fail even though the graph
converges correctly; wrap them in a Scope, as the editor's own export does. See
[../process-file-format/exception-handler-rules.md](../process-file-format/exception-handler-rules.md).

## The standard pattern
Throw a signal inside a scope → catch it outside → hand off to a shared handler Subprocess → end.
Detail and the worked shape are in [../guides/error-handling.md](../guides/error-handling.md). For
the exact current scope/retry options, fetch the live docs rather than assuming, since they evolve.

## Source of truth
`https://docs.frends.com/reference/shapes/scope-shapes/scope.md`,
`https://docs.frends.com/reference/shapes/event-shapes/catch.md`
