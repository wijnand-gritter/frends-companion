# Sequence Flow

**Category:** shape (connection) · **Baseline:** Frends 6.2

## Purpose
The arrow that wires one shape to the next and defines execution order. On a gateway, the outgoing
sequence flow also carries the **branch label/condition** (e.g. "yes"/"no").

## Fields / configuration
- A `name` used as the branch label on [Decision](exclusive-decision.md) outputs.
- For gateway branches, the branch condition is associated with the flow.

## Serialization
BPMN `sequenceFlow` (`sourceRef`/`targetRef`, optional `name`); JSON `Type` **4**. Confirmed: gateway
branches appear as Type 4 entries named e.g. `yes` / `no`. See
[../process-file-format/bpmn-xml.md](../process-file-format/bpmn-xml.md) and
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Source of truth
`https://docs.frends.com/reference/shapes/sequence-flow.md`
