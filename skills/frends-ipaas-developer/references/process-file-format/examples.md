# Bundled examples

Real Frends 6.2 exports, in `examples/`:

- `examples/api_process_http_trigger_6.2.json` — a full HTTP API Process export (proprietary JSON):
  an `HttpApiTrigger` (route, method, references, embedded OpenAPI), a JSON-validation
  [Task](../shapes/task.md), a [Call Subprocess](../shapes/call-subprocess.md) (Type 7), an exclusive
  Gateway, an embedded scope, and `HttpResult` [Return](../shapes/return.md)/[Throw](../shapes/throw.md)
  shapes. The authoritative example for full Processes and HTTP triggers. One email redacted; UTF-8 BOM.
- `examples/subprocess_export_6.2.json` — a full Subprocess export (proprietary JSON), the
  `[Shared] - Generic error handler`: the envelope, `ElementParameters` with real `{mode,value}`
  leaves, two Code Tasks, a Slack SendMessage Task, a Return, and Environment Variable references.
  One email redacted; UTF-8 BOM.
- `examples/subprocess_export_6.2.bpmn` — the same Subprocess as a diagram-only BPMN export (same
  shape ids). Compare with its JSON twin to see exactly what the BPMN format omits.
- `examples/process_export_6.2.bpmn` — a parent Process (diagram only) showing the error pattern: a
  manual start, an embedded `subProcess` scope with an `exclusiveGateway` and a signal
  `intermediateThrowEvent`, an `intermediateCatchEvent`, and a `callActivity` to the shared
  error-handler Subprocess above. See [bpmn-xml.md](bpmn-xml.md) and
  [../guides/error-handling.md](../guides/error-handling.md).
- `examples/scope_catch_export_6.2.json` — a full Process export whose catch branch is itself a
  Scope: the authoritative example for [exception-handler-rules.md](exception-handler-rules.md)
  (two outgoing flows, catch listed first, one node in the catch branch, the gateway and the signal
  `intermediateThrowEvent` nested inside that branch's Scope). It also carries the only confirmed
  Type 18 `globalErrorHandler` entry, documented in
  [unhandled-error-hook.md](unhandled-error-hook.md), and a Type 6 Throw with
  `bypassGlobalExceptionHandler`. UTF-8 BOM.
