# Shape Type codes (JSON)

Each `ElementParameters` entry is `{ "Id", "Type", "SelectedTypeId", "Parameters" }`. The `Id`
matches a BPMN element id. The integer `Type` is Frends' internal shape code.

**Provenance:** the codes below are **confirmed against real Frends 6.2 exports** — including an
"All Icons" palette export (FrendsVersion 6.2.3.3649, net8.0) that places every trigger and nearly
every shape on one canvas — unless a row says otherwise. Where a 5.7 template used a different code,
it is noted. Each row links to the shape's reference file.

| Type | BPMN element | Shape | `SelectedTypeId` | Status |
| --- | --- | --- | --- | --- |
| 0 | `startEvent` | [Trigger](../triggers/) | trigger `$type` (see below) | confirmed |
| 1 | `task` | [Task](../shapes/task.md) | `/ProcessTask/{guid}/v{n}` | confirmed |
| 2 | `exclusiveGateway` | [Exclusive Decision](../shapes/exclusive-decision.md) | None | confirmed |
| 4 | `sequenceFlow` | [Sequence Flow](../shapes/sequence-flow.md) | None | confirmed |
| 5 | `endEvent` | [Return](../shapes/return.md) | `Expression` / `HttpResult` | confirmed |
| 6 | `intermediateThrowEvent` | [Throw](../shapes/throw.md) | `HttpResult` (API) | confirmed |
| 7 | `callActivity` | [Call Subprocess](../shapes/call-subprocess.md) | called Subprocess GUID | confirmed |
| 8 | `subProcess` | [Scope](../shapes/scope-and-catch.md) (plain embedded scope) | None | confirmed |
| 10 | `subProcess` | [Foreach](../shapes/loop.md) | None | confirmed |
| 11 | `subProcess` | [While](../shapes/loop.md) | None | confirmed |
| 12 | `scriptTask` | [Code Task](../shapes/code-task.md) | None | confirmed |
| 13 | `startEvent` (nested) | Scope start node (`SubProcessStartNode`) | "" | confirmed |
| 14 | `intermediateCatchEvent` | [Catch](../shapes/scope-and-catch.md) | None | confirmed |
| 17 | `endEvent` | [Intermediate Return](../shapes/intermediate-return.md) | None | confirmed |
| 20 | `businessRuleTask` | [Shared State Task](../shapes/shared-state-task.md) | operation: `AddOrUpdate`, `TryGetValue`, ... | confirmed |
| 21 | `businessRuleTask` | [DMN Task](../shapes/dmn-task.md) | `Dmn` | confirmed (6.2) |
| 22 | `dataObjectReference` | [Data Object Reference](../shapes/data-object-reference.md) | None | confirmed (6.2) |
| 23 | `dataStoreReference` | [Data Store Reference](../shapes/data-store-reference.md) | None | confirmed (6.2) |
| 24 | `intermediateCatchEvent` | [Checkpoint](../shapes/checkpoint.md) | None | confirmed |
| 25 | `intermediateCatchEvent` | [Scheduled Resume](../shapes/scheduled-resume.md) | None | confirmed |
| 26 | `intermediateCatchEvent` | [Signal Resume](../shapes/signal-resume.md) | None | confirmed |
| 27 | `task` | [AI Connector](../shapes/ai-connector.md) | `NativeAi` | confirmed |

Notes:
- A Scope, a Foreach, and a While all render as BPMN `subProcess`; the `Type` (8 / 10 / 11)
  distinguishes them. Each embedded scope contains its own `startEvent` recorded as `Type` 13.
- Shared State (20) and DMN (21) both render as `businessRuleTask`; the `Type` and `SelectedTypeId`
  distinguish them. The AI Connector (27) renders as a plain `task`.
- Catch (14), Checkpoint (24), Scheduled Resume (25), and Signal Resume (26) all render as
  `intermediateCatchEvent`; the `Type` and their distinct `Parameters` keys tell them apart (see
  [confirmed-shape-parameters.md](confirmed-shape-parameters.md)).

## Still unconfirmed (not present in available exports)
- **Inclusive Decision** (`inclusiveGateway`) and its branch — code not yet observed. Validate
  against an export that uses one.
- **Assign Variable** (the API `ElementType` calls this `Expression`) — code not yet observed. An
  earlier note guessed Type 8, but 8 is confirmed to be a Scope; Assign Variable's code is unknown.
- **Group** and **Text Annotation** — documentation shapes that appear in the BPMN as
  `group` / `textAnnotation` but do not get an `ElementParameters` entry. See
  [../shapes/group.md](../shapes/group.md) and [../shapes/text-annotation.md](../shapes/text-annotation.md).
- **Global Error Handler** (`GlobalErrorHandler`) and `TestTask` — not observed.

## 5.7 vs 6.2 drift
Codes 19–22 differ between 5.7 templates and 6.2 exports. In the 77 marketplace 5.7 templates, code
19 carried a `/ProcessTask/...` ref and codes 21/22 appeared to be data object/store references. In
real 6.2 data, 21 is the DMN Task, and the data object/store references are 22/23. **Trust the 6.2
values above for 6.2 work**; treat 5.7 template codes as that-version-specific.

> When you add a shape, add its row here and to [bpmn-xml.md](bpmn-xml.md)'s mapping table, and link
> both from the shape's file. See [../../CONTRIBUTING.md](../../CONTRIBUTING.md).
