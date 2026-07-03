# Confirmed shape parameter structures (6.2)

From the bundled 6.2 exports, the real per-shape shapes. Each links to the shape's reference file.

## [Code Task](../shapes/code-task.md) (Type 12)
Holds its C# in `variableExpression`, plus toggles and a target name:
```json
{ "useStatementMode":   { "mode": "toggle", "value": true },
  "variableExpression": { "mode": "csharp", "value": "var x = #trigger.data.error; ..." },
  "shouldAssignVariable": { "mode": "toggle", "value": true },
  "variableName": "errorEvent" }
```
`variableName` is a plain string (not a `{mode,value}` leaf). When `shouldAssignVariable` is on, the
code's `return` value is assigned to `#var.<variableName>`.

## [Task](../shapes/task.md) (Type 1)
Groups parameters under the Task's classes, each leaf a `{mode,value}`. Real example from a Slack
SendMessage Task, with secrets pulled from Environment Variables:
```json
{ "input":      { "ChannelId": { "mode": "text",   "value": "{{#env.SLACK_CONNECTION.channelId}}" },
                  "Mode":      { "mode": "select", "value": "Blocks" },
                  "Blocks":    { "mode": "text",   "value": "{{#var.slackMessage}}" } },
  "connection": { "Token":     { "mode": "text",   "value": "{{#env.SLACK_CONNECTION.token}}" } },
  "options":    { "ThrowErrorOnFailure": { "mode": "toggle", "value": true } },
  "cancellationToken": null }
```
Env references use Handlebars in a `text`-mode field (`{{#env.Group.Name}}`); the Task ref lives in
the entry's `SelectedTypeId` (`/ProcessTask/<guid>/v1`).

## [Return](../shapes/return.md) (Type 5)
Carries an `expression` leaf; here it returns a variable via Handlebars text:
```json
{ "expression": { "mode": "text", "value": "{{#var.errorEvent}}" } }
```

## [Manual Trigger](../triggers/manual.md) (Type 0, `SelectedTypeId: "ManualTrigger"`)
With a parameter: the start entry holds `manualTriggerDefaultValue-0`, `ManualTriggerJson` describes
the parameter's type (`TextParameter`, `System.String`, etc.), and `TriggersJson` `config` carries
the default.

## [HTTP API Trigger](../triggers/api.md) (Type 0, `SelectedTypeId: "HttpApiTrigger"`)
Confirmed `TriggersJson` config:
```json
{ "$type": "HttpApiTrigger",
  "config": {
    "routeTemplate": "api/projects-hours/v1/hour-registrations",
    "isPrivate": false, "corsEnabled": false, "allowedOrigins": "",
    "allowedSchemes": "HTTP,HTTPS", "httpMethod": "POST",
    "references": [ "data", "data.body", "data.body.employeeId", "claimsprincipal", ... ],
    "openApiDocument": "openapi: 3.0.4\ninfo:\n  title: ..." } }
```
`references` lists the `#trigger.data.*` (and `claimsprincipal.*`) paths the editor exposes for
auto-complete, typically derived from the OpenAPI body schema. The full OpenAPI contract is embedded
as a string in `openApiDocument`.

## HTTP API Return (Type 5, `SelectedTypeId: "HttpResult"`)
```json
{ "httpResult": {
    "httpStatusCode":      { "mode": "integer", "value": 201 },
    "httpContentType":     { "mode": "text",    "value": "application/json" },
    "httpContent":         { "mode": "json",    "value": "{ \"id\": \"string\" }" },
    "httpContentEncoding": { "mode": "text",    "value": "utf-8" },
    "httpHeaders": [] } }
```
A JSON-validation Task in the same Process shows `input.Json` set to `#trigger.data.httpBody` and
`input.JsonSchema` set to a JSON Schema string, both in `json` mode — validating an incoming API body
against a contract.

## Additional shapes (confirmed from the 6.2 "All Icons" palette export)

[Intermediate Return](../shapes/intermediate-return.md) (Type 17): `{ "expression": {mode,value} }`
(like a Return but continues execution).

[Catch](../shapes/scope-and-catch.md) (Type 14): `{ "expression": "error" }` — a plain string naming
the error variable, not a `{mode,value}` leaf.

[Shared State Task](../shapes/shared-state-task.md) (Type 20, `SelectedTypeId` = operation e.g.
`AddOrUpdate`):
```json
{ "keyExpression": {"mode":"text","value":"key"}, "valueExpression": {"mode":"csharp","value":"#result"},
  "ttlValue": {"mode":"integer","value":60}, "ttlMultiplier": 60, "throwIfFalse": true, "isGlobalScope": false }
```
(`ttlMultiplier`/`throwIfFalse`/`isGlobalScope` are plain values, not `{mode,value}` leaves.)

[DMN Task](../shapes/dmn-task.md) (Type 21, `SelectedTypeId: "Dmn"`):
`{ "useDmnMode": {mode,value toggle}, "dmnXml": "<definitions ...>...</definitions>" }` (DMN model XML
as a plain string).

[AI Connector](../shapes/ai-connector.md) (Type 27, `SelectedTypeId: "NativeAi"`): keys
`useNativeAiMode`, `useCustomOptions`, `optionsJson`, `serviceType`, `modelName`, `systemPrompts[]`
(each prompt a `{mode,value}` text leaf).

[Checkpoint](../shapes/checkpoint.md) (Type 24):
`{ "correlationId": {mode csharp}, "ttlMinutes": {mode integer}, "continueExecution": {mode toggle} }`.

[Scheduled Resume](../shapes/scheduled-resume.md) (Type 25):
`{ "maxIterations": {mode integer}, "rehydrationIntervalMinutes": {mode integer} }`.

[Signal Resume](../shapes/signal-resume.md) (Type 26):
`{ "useSignalRehydrationMode": {mode toggle}, "correlationId": {mode csharp} }`.

[Data Object](../shapes/data-object-reference.md) (22) / [Data Store](../shapes/data-store-reference.md)
(23): empty `Parameters` (`{}`).
