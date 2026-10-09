# Conditional Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Starts a Process based on a condition, often by calling a [Subprocess](../concepts/subprocess.md)
that polls or evaluates state (for example polling an SFTP directory for changes).

## Configuration
The condition/polling setup, frequently delegated to a Subprocess. Confirm the exact `config` field
set against the live docs or a real export.

## Expressions and references
Trigger parameter fields are Text with the `#env` exception; see
[parameter-fields.md](parameter-fields.md).

## Serialization
JSON `Type` 0, `SelectedTypeId: "ConditionalTrigger"`. **Confirmed** 6.2 `config` keys:
`pollingInterval`, `processGuid` (the Subprocess it polls), `limitToOneConcurrentExecution`,
`parameters`. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## When to use it
Prefer a Conditional Trigger to a frequent Schedule that mostly finds nothing: fewer empty runs and a
cleaner Instance list. Keep the condition simple and free of business logic that changes data
(Frends best practices collection).

## Source of truth
`https://docs.frends.com/reference/triggers/conditional-trigger.md`
