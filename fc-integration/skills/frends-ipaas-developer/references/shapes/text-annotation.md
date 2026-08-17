# Text Annotation shape

**Category:** shape · **Baseline:** Frends 6.3 (serialization confirmed against a production-tenant export)

## Purpose
A canvas comment, optionally attached to a shape with an association line. Documentation-only.

## Serialization (confirmed)
- BPMN: `<bpmn2:textAnnotation id="TextAnnotation_x"><bpmn2:text>The comment</bpmn2:text></bpmn2:textAnnotation>`
  and, when attached, `<bpmn2:association id="Association_y" associationDirection="None"
  sourceRef="<shape id>" targetRef="TextAnnotation_x" />` - both inside the process element.
- DI: a `BPMNShape` for the annotation and a `BPMNEdge` for the association. Association edges
  **may be diagonal** (unlike sequence flows, which stay orthogonal).
- **No `ElementParameters` entries** for the annotation or the association.

## Source of truth
`https://docs.frends.com/reference/shapes/artifact-shapes/text-annotation.md`; serialization
confirmed against a Frends 6.3 export.
