# Group shape

**Category:** shape · **Baseline:** Frends 6.3 (serialization confirmed against a production-tenant export)

## Purpose
A labelled visual region on the canvas with **no execution semantics** - it does not contain
shapes, affect joins, or appear in the structured-flow analysis. Use it to mark a logical phase
across top-level shapes without introducing a Scope.

## Serialization (confirmed)
- BPMN: `<bpmn2:group id="Group_x" categoryValueRef="CategoryValue_y" />` inside the process, plus
  the label defined as a **sibling of the process element** inside `definitions`:
  `<bpmn2:category id="Category_z"><bpmn2:categoryValue id="CategoryValue_y" value="The label" /></bpmn2:category>`
- DI: a `BPMNShape` with bounds and a `BPMNLabel`.
- **No `ElementParameters` entry** - groups (like text annotations and associations) are
  documentation-only and absent from the EP list entirely.

## Source of truth
`https://docs.frends.com/reference/shapes/artifact-shapes/group.md`; serialization confirmed
against a Frends 6.3 export.
