# Inclusive Decision shape

**Category:** shape · **Baseline:** Frends 6.2 (serialization confirmed against a 6.3.2.5468 export)

## Purpose
Multiple branches that can run together. Each branch has its own boolean expression; **every branch
whose expression is `True` executes**. An optional default runs if none did.

## Fields / configuration
- One boolean C# expression per branch, **locked to C# Expression**, each validated to resolve to
  `bool`.
- Optional default branch.

## Expressions and references
C# booleans per branch. See [../expressions/reference-syntax.md](../expressions/reference-syntax.md).

## Serialization
Confirmed against a 6.3.2.5468 export
([../process-file-format/examples/mcp_rabbitmq_inclusive_export_6.3.json](../process-file-format/examples/mcp_rabbitmq_inclusive_export_6.3.json)).

BPMN: an `inclusiveGateway`. When there is a default branch, the gateway carries
`default="<flowId>"`, as the Exclusive Decision does. The branches are plain `sequenceFlow`
elements whose `name` is the branch label; the BPMN holds no condition.

```xml
<bpmn2:inclusiveGateway id="InclusiveGate" name="Choose harvest branches" default="InclusiveGate_BranchB">
  ...
<bpmn2:sequenceFlow id="InclusiveGate_BranchA" sourceRef="InclusiveGate" targetRef="BranchA" name="Always take branch A" />
<bpmn2:sequenceFlow id="InclusiveGate_BranchB" sourceRef="InclusiveGate" targetRef="BranchB" name="Default branch B" />
```

JSON: the gateway is `Type` 15 with empty `Parameters` and `SelectedTypeId: null`. Each branch is
its own `ElementParameters` entry of `Type` 16 (the API `ElementType` `InclusiveDecisionBranch`),
with `SourceId`, `TargetId`, `Name` and `IsDefault`:

```json
{ "Id": "InclusiveGate", "Type": 15, "Parameters": {}, "SelectedTypeId": null,
  "Name": "Choose harvest branches" },
{ "TargetId": "BranchA", "SourceId": "InclusiveGate", "Id": "InclusiveGate_BranchA", "Type": 16,
  "Parameters": { "expression": { "value": "true", "mode": "csharp" } },
  "Name": "Always take branch A", "IsDefault": false },
{ "TargetId": "BranchB", "SourceId": "InclusiveGate", "Id": "InclusiveGate_BranchB", "Type": 16,
  "Parameters": {}, "Name": "Default branch B", "IsDefault": true }
```

- A conditional branch holds its condition in `Parameters.expression`, mode `csharp`.
- The default branch has empty `Parameters` and `IsDefault: true`. At most one branch is the default.
- The other `ElementParameters` keys (`PromoteResultAs`, `Description`, `ShouldRetry`, ...) are
  present and `null`; they are trimmed above.
- The plain connections after the branches (branch body to the joining shape) have no
  `ElementParameters` entry; they exist only in the BPMN.

See [../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md).

## Joining and the result
Every branch must reach one common joining shape. The MCP builder rejects branches that end
separately or join at a second gateway, with "Inclusive decision nodes have to have a common joining
point". Downstream, `#result[<gateway name>]` is a dictionary keyed by branch that holds each taken
branch's last result (MCP builder description; not observed at runtime, as the test Process was
never run).

## Gotchas
Unlike Exclusive, more than one branch can fire — design downstream merges accordingly.

From 6.3.1 the shape has "Skip logging result and parameters", like Task shapes; set it when a
branch condition reads sensitive data. Branch names cannot contain a double quote.

**Not parallel.** The branches that fire run one after another, in creation order. Do not use an
Inclusive Decision to speed a Process up (Frends process optimisation guide).

## Source of truth
`https://docs.frends.com/reference/shapes/decision-shapes/inclusive-decision.md`
