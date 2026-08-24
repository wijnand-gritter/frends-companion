# Subprocess

**Category:** concept · **Baseline:** Frends 6.2

## Purpose
A **Subprocess** is a [Process](process.md) designed to be called from other Processes, for reuse.
Call it from a parent with the [Call Subprocess](../shapes/call-subprocess.md) shape.

## Key facts
- A Subprocess must be **deployed before** any Process that uses it, or the parent's deploy fails
  (see [../guides/deployment.md](../guides/deployment.md)).
- Subprocesses appear in their own list view and deploy exactly like Processes.
- Give a Subprocess clear input parameters and a well-defined return so callers can treat it as a
  black box.
- In an export it is flagged `IsSubprocess: true`; see
  [../process-file-format/proprietary-json.md](../process-file-format/proprietary-json.md).

## Source of truth
`https://docs.frends.com/reference/process-development/subprocess.md`
