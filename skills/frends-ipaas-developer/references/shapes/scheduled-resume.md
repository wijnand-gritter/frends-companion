# Scheduled Resume shape

**Category:** shape (long-running) · **Baseline:** Frends 6.2

## Purpose
Pauses the Process and resumes it after a specified wait, looping back to a [Checkpoint](checkpoint.md).
The basis for polling/wait logic — effectively a While loop with a wait between iterations. It is the
only shape that makes a looping Process flow possible.

## Fields / configuration
- **Maximum Number of Iterations** — how many times it may pause before ending in failure (max Int32).
- **Resume Interval** — minutes to wait before resuming; also the gap between iterations (max Int32).

## Usage constraints
Must be connected after an [Exclusive Decision](exclusive-decision.md) so a branch flows back to the
Checkpoint; the next shape after Scheduled Resume must be the Checkpoint. Checkpoint stores state, not
Scheduled Resume — data created in the Scheduled Resume branch is not persisted. A paused Process can
still be resumed early by a [Signal Resume](signal-resume.md) elsewhere.

## Serialization
BPMN `intermediateCatchEvent`; JSON `Type` **25**. Confirmed `Parameters`:
```json
{ "maxIterations":              { "mode": "integer", "value": 1 },
  "rehydrationIntervalMinutes": { "mode": "integer", "value": 60 } }
```
See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/long-running-process-shapes/scheduled-resume.md`
