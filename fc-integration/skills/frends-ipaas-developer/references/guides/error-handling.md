# Guide: error handling

Design for failure explicitly rather than letting a Task throw into the void.

## Building blocks
- Use a [Throw](../shapes/throw.md) shape to end a path as a controlled error with a meaningful
  message.
- Branch on error conditions with an [Exclusive Decision](../shapes/exclusive-decision.md) (e.g.
  check a Task result's status before continuing).
- Use a [Scope and Catch](../shapes/scope-and-catch.md) to contain work and catch thrown
  signals/errors.
- Use [Subprocesses](../concepts/subprocess.md) to encapsulate a unit of work with its own
  success/failure handling.

## The standard Frends pattern
Confirmed in the bundled 6.2 example: an embedded scope does the work and contains an exclusive
gateway whose "yes" branch goes to a Throw with a signal definition. Outside the scope, a Catch with
a matching signal definition catches it and routes to a `callActivity` named like
`[Shared] - Generic error handler` (a shared error-handling Subprocess), then to the end. So: **throw
a signal inside a scope, catch it outside, hand off to a shared handler Subprocess.** Model new error
handling on this shape. The serialization is in
[../process-file-format/bpmn-xml.md](../process-file-format/bpmn-xml.md).

## When in doubt, fetch
For the exact current options (try/catch-style scopes, on-error routing, retries), fetch the live
docs rather than assuming, since these evolve. Suggested query:
`https://docs.frends.com/reference/process-development.md?ask=what error handling and retry options are available in a Process`.
See [staying-current.md](staying-current.md).
