# Format 1: BPMN XML (diagram only)

Confirmed root (identical across 5.7 and 6.2):
```xml
<bpmn2:definitions
  xmlns:bpmn2="http://www.omg.org/spec/BPMN/20100524/MODEL"
  xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
  xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"
  xmlns:di="http://www.omg.org/spec/DD/20100524/DI"
  id="sample-diagram" targetNamespace="http://bpmn.io/schema/bpmn">
  <bpmn2:process id="Process_1" isExecutable="false"> ... </bpmn2:process>
  <bpmndi:BPMNDiagram> ... layout ... </bpmndi:BPMNDiagram>
</bpmn2:definitions>
```
Element ids are bpmn.io-style (e.g. `Activity_0o7vxxp`, `Flow_1twq9s7`, `Event_15jgm2j`).
`isExecutable="false"` on the process. Each flow node lists its `incoming` and `outgoing` flow ids;
`sequenceFlow` carries `sourceRef`/`targetRef` and an optional `name` used as a branch label.

## Shape to BPMN element mapping
Left column is the Frends Process Editor shape; middle is the BPMN element emitted in 6.2; right is
the JSON `Type` code (see [shape-type-codes.md](shape-type-codes.md)). Each shape's own reference
file links back to this row.

| Frends shape | BPMN element (6.2) | JSON Type |
| --- | --- | --- |
| [Trigger](../triggers/) (start) | `startEvent` (e.g. `name="Manual"`) | 0 |
| [Task](../shapes/task.md) | `task` | 1 |
| [Code Task](../shapes/code-task.md) | `scriptTask` | 12 |
| [Exclusive Decision](../shapes/exclusive-decision.md) | `exclusiveGateway` (has `default="<flowId>"`) | 2 |
| [Inclusive Decision](../shapes/inclusive-decision.md) | `inclusiveGateway` (inferred; not in samples) | (n/a in sample) |
| [Return](../shapes/return.md) | `endEvent` | 5 |
| [Throw](../shapes/throw.md) | `intermediateThrowEvent` (+ `signalEventDefinition`) | 6 |
| Catch ([scope-and-catch](../shapes/scope-and-catch.md)) | `intermediateCatchEvent` + `signalEventDefinition` | (n/a in 5.7 sample) |
| [Scope](../shapes/scope-and-catch.md) / embedded subprocess | `subProcess` (`isExpanded="true"`) | 10 / 11 |
| Scope start | `startEvent` nested in a `subProcess` | 13 |
| [Call Subprocess](../shapes/call-subprocess.md) | `callActivity` (`name` is the called Process) | 7 |
| Shared State operation | `businessRuleTask` | 20 |
| Data object | `dataObjectReference` | 21 |
| Data store (Shared State) | `dataStoreReference` | 22 |
| Connection / branch | `sequenceFlow` (`name` = branch label "yes"/"no") | 4 |
| Annotation / comment | `textAnnotation` + `association` | (visual only) |

Notes: a `task` is a configured Frends Task; a `scriptTask` is inline C#. A `subProcess` here is an
embedded scope drawn inline (the 6.2 example expands one with `isExpanded="true"`), different from a
`callActivity` that calls a separately deployed Subprocess by name. Type 13 start events are the
start node inside an embedded scope.

## The error-handling pattern (throw / catch / call)
The 6.2 process example shows the standard Frends error-handling shape: an embedded `subProcess`
does the work and contains an `exclusiveGateway` whose "yes" branch goes to an
`intermediateThrowEvent` with a `<signalEventDefinition/>`. Outside the scope, an
`intermediateCatchEvent` with a matching `<signalEventDefinition/>` catches that signal and routes to
a `callActivity` named like `[Shared] - Generic error handler` (a shared error-handling Subprocess),
then to the `endEvent`. That is the serialization to copy. The flow itself ends a handled failure
at the end event, which records the run as successful: new Processes end the catch branch in a
Throw instead. See [../guides/error-handling.md](../guides/error-handling.md).
