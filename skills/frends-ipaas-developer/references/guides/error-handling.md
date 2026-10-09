# Guide: error handling

Design for failure explicitly. Every run ends in a state that says what happened: a successful run
at a Return, a failed run at a Throw. The conventions below are the Frends best practices
collection; where the organisation has its own written standard, that standard wins (see
[../../SKILL.md](../../SKILL.md), "Platform facts vs conventions").

## Building blocks
- [Throw](../shapes/throw.md): ends a path as a failed run with a meaningful message.
- [Exclusive Decision](../shapes/exclusive-decision.md): branches on a Task result's status.
- [Scope and Catch](../shapes/scope-and-catch.md): contains work and catches its exceptions.
- A shared error-handler [Subprocess](../concepts/subprocess.md), called from every catch.
- The unhandled-error hook, the last resort (below).

## Outcome decides the end shape

| Outcome | End shape | Instance status | Notify |
| --- | --- | --- | --- |
| Success | Return | success | no |
| Request rejected with a structured 4xx answer (validation, business rule) | Return, with the error envelope | success | no |
| Upstream failure, unexpected exception, failed entity in a batch | Throw | failed | yes |

Two platform facts drive this:
- **A caught error that ends at an end event records the run as successful.** It does not show on
  the Dashboard's Failed Processes widget and no monitoring rule sees it. A handled failure must
  therefore still end in a Throw.
- **A request the Process validated and answered is not a failure.** Marking it failed floods
  monitoring with the caller's mistakes. Answer it with a Return.

## Expected failures: detect from results, answer with a Return
Validation failures and business rejections are expected outcomes. Detect them from returned
results, not exceptions:
- Leave `ThrowExceptionOnErrorResponse` at `false` on the Task, so a non-2xx comes back as a result.
- Branch with an Exclusive Decision on `#result[Task].Success` (or the Task's status field).
- Terminate the rejection branch in its own Return carrying the 4xx and the error envelope.

The branching gateway must not come **after** a Scope that has a Catch: nothing branches after such
a scope ([exception-handler-rules.md](../process-file-format/exception-handler-rules.md) rule 4), and
a Return inside a scope only ends the scope. So a call whose rejection is answered with a 4xx stays
outside the caught scope, with its gateway on the main lane; its unexpected exceptions go to the
unhandled-error hook (below).

## Unexpected failures: scope, catch, handler, Throw
1. The work runs inside a Scope.
2. A Catch outside it receives the exception into a named error variable.
3. The catch branch is **one** Scope (import rule 3). Inside it:
   `Call Shared - Handle process error` → Throw.
4. For an API Process the Throw is an `HttpResult` 5xx carrying the error envelope.
5. Set `bypassGlobalExceptionHandler` on that Throw. The handler already ran; without the bypass the
   unhandled-error hook reports the same failure a second time.

```
Scope "Process request"
  ... work ...
Catch (error)
  Scope "Handle failure"
    Call Shared - Handle process error
    Throw HttpResult 500   (error envelope, bypassGlobalExceptionHandler = true)
Return HttpResult 204
```

The scope's other outgoing flow and the catch scope both target the same Return (import rules 1 to
3). Wiring detail: [exception-handler-rules.md](../process-file-format/exception-handler-rules.md).

**Open point:** whether `httpStatusCode` on an `HttpResult` Return accepts an expression is not
confirmed. If it does, one Return with a status from `#var.response` can serve success and 4xx
alike. Ask the developer for an export before relying on it.

## Loops: continue per entity, fail the run at the end
1. Each iteration gets its own Scope and Catch. The catch scope calls the handler with the entity in
   the context, records the failure in a `#var` and ends without a Throw, so the next entity runs.
2. After the loop, an Exclusive Decision on the recorded failures ends the run in a Throw (with
   `bypassGlobalExceptionHandler`) when any entity failed, and in a Return otherwise.

The loop is not a caught scope, so the gateway after it is allowed.

## Retry
- Retry transient failures only: timeouts, 429, 502, 503, 504, connection loss.
- Never retry a validation or business error: it fails again unchanged.
- Retry idempotent operations only, with a limited count (default five, maximum ten).
- Mechanics, backoff and the `ThrowExceptionOnErrorResponse` interaction: [../shapes/task.md](../shapes/task.md).

## Unhandled errors: the last-resort hook
Process settings offer **"Select Subprocess to call on unhandled error"**: the chosen Subprocess
runs whenever the Process dies with an uncaught exception or a Throw without the bypass. It is
reporting and cleanup only: it cannot resume the run, and the platform provides **no loop
protection** if the handler itself fails.

| Process | Hook | Why |
| --- | --- | --- |
| Business processes | the shared error handler, `error` = `#error` | covers failures before the first scope and bugs in a catch branch |
| Error-event listener | **empty** | a failing listener would publish an event it then consumes, amplifying the queue; its queue retry and dead-letter are the safety net |
| The shared error handler | **empty** | the handler's own failure must terminate |

Two design rules make the shared handler safe as this hook:
1. **It never throws**: its publish step has its own catch that sets a flag and returns normally.
2. **Circuit breaker**, first thing in the handler:

```csharp
// Never publish an error event about the error pipeline itself.
// Substitute the names your tenant uses for the handler and the listener.
if (processName == "<your error-event listener>"
    || processName == "<your shared error handler>") return null;
```

Serialization of the hook: [unhandled-error-hook.md](../process-file-format/unhandled-error-hook.md).

## Naming
Frends' own bundled examples use `[Shared] - Generic error handler`. The Frends best practices
collection rules out brackets in Process names; default to `Shared - Handle process error` and keep
the name the organisation's standard prescribes where it has one. See
[best-practices.md](best-practices.md).

## Review
Check a built Process against these rules with the `frends-reviewer` skill.

## Sources
- `https://docs.frends.com/guides/general/frends-best-practices-collection.md`
- `https://docs.frends.com/guides/development/how-to-handle-errors-in-frends-processes.md`
- `https://docs.frends.com/guides/general/common-errors-and-faq.md` (caught errors ending in an End
  are not shown as failed)
