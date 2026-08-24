# Throw shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
End a path by raising a controlled error with a meaningful message, instead of letting a Task throw
into the void.

## Fields / configuration
An error/message field (Text supports Handlebars, e.g.
`"Customer {{#var.order.CustomerId}} not found"`). In the standard error pattern a Throw inside a
scope emits a signal that a [Catch](scope-and-catch.md) handles outside.

## Serialization
BPMN `intermediateThrowEvent` (with a `signalEventDefinition` for signal/error); JSON `Type` **6**;
for an HTTP API, `SelectedTypeId: "HttpResult"`. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md) and the
error-handling pattern in [../guides/error-handling.md](../guides/error-handling.md).

## Source of truth
`https://docs.frends.com/reference/shapes/event-shapes/throw.md`
