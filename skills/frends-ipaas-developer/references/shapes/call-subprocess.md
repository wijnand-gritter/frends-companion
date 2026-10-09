# Call Subprocess shape

**Category:** shape · **Baseline:** Frends 6.2

## Purpose
Call another deployed [Subprocess](../concepts/subprocess.md) from the current Process, passing
input parameters and using its return.

## Fields / configuration
The called Subprocess (selected by GUID) and its input parameters.

## Expressions and references
Inputs are ordinary shape fields (Expression/Text). The Subprocess's return is available as a result
of this shape.

## Serialization
BPMN `callActivity` (`name` = the called Process); JSON `Type` **7**; `SelectedTypeId` is the called
Subprocess GUID, and the call is also recorded in `UsedSubprocessesJson`
(e.g. `{ "<subprocessGuid>": ["__localCall"] }`). Confirmed for 6.2. See
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Gotchas
The Subprocess must be **deployed to the target before** the parent, or the parent's deploy fails
(see [../guides/deployment.md](../guides/deployment.md)).

**Every call serialises its parameters and result.** The cost is paid per call whatever the
Subprocess does, so a one- or two-shape Subprocess called inside a large loop is a performance
defect. **Remote Subprocesses** (executed on another Agent Group) add network overhead: avoid them
in high-volume Processes and APIs, pass identifiers only, and expect a timeout on payloads of
10 MB and more (Frends best practices collection; common errors and FAQ).

## Source of truth
`https://docs.frends.com/reference/shapes/activity-shapes/call-subprocess.md`
