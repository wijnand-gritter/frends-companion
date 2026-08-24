# Shapes — index

Anything placed on the Process canvas. Each file follows the shared template (Purpose → Fields/modes
→ Expressions → Serialization → Gotchas → Example). Type codes are authoritative in
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md) (confirmed
against real 6.2 exports).

| File | Shape | BPMN / JSON Type |
| --- | --- | --- |
| [task.md](task.md) | Task (runs a Frends Task) | `task` / 1 |
| [code-task.md](code-task.md) | Code Task (inline C#) | `scriptTask` / 12 |
| [exclusive-decision.md](exclusive-decision.md) | Exclusive Decision (either/or) | `exclusiveGateway` / 2 |
| [inclusive-decision.md](inclusive-decision.md) | Inclusive Decision (multi-branch) | `inclusiveGateway` / (unconfirmed) |
| [assign-variable.md](assign-variable.md) | Assign Variable | `scriptTask` / 12 (distinguished by `variableName` params) |
| [loop.md](loop.md) | Foreach / While | `subProcess` / 10, 11 |
| [scope-and-catch.md](scope-and-catch.md) | Scope + Catch | `subProcess` / 8, scope start 13; Catch `intermediateCatchEvent` / 14 |
| [call-subprocess.md](call-subprocess.md) | Call Subprocess | `callActivity` / 7 |
| [shared-state-task.md](shared-state-task.md) | Shared State Task | `businessRuleTask` / 20 |
| [dmn-task.md](dmn-task.md) | DMN Task | `businessRuleTask` / 21 |
| [ai-connector.md](ai-connector.md) | AI Connector | `task` / 27 |
| [return.md](return.md) | Return (normal end) | `endEvent` / 5 |
| [intermediate-return.md](intermediate-return.md) | Intermediate Return (respond + continue) | `endEvent` / 17 |
| [throw.md](throw.md) | Throw (error end) | `intermediateThrowEvent` / 6 |
| [checkpoint.md](checkpoint.md) | Checkpoint (store state / dehydrate) | `intermediateCatchEvent` / 24 |
| [scheduled-resume.md](scheduled-resume.md) | Scheduled Resume (wait + loop) | `intermediateCatchEvent` / 25 |
| [signal-resume.md](signal-resume.md) | Signal Resume (resume another Process) | `intermediateCatchEvent` / 26 |
| [data-object-reference.md](data-object-reference.md) | Data Object (doc only) | `dataObjectReference` / 22 |
| [data-store-reference.md](data-store-reference.md) | Data Store (doc only) | `dataStoreReference` / 23 |
| [group.md](group.md) | Group (doc only) | `group` / (no entry) |
| [text-annotation.md](text-annotation.md) | Text Annotation (doc only) | `textAnnotation` / (no entry) |
| [sequence-flow.md](sequence-flow.md) | Sequence Flow (wiring/branch) | `sequenceFlow` / 4 |

To add a shape: copy [../_TEMPLATE.md](../_TEMPLATE.md) here, add a row above, add a Type-code row to
the spec, add a router line to [../../SKILL.md](../../SKILL.md). See
[../../CONTRIBUTING.md](../../CONTRIBUTING.md).
