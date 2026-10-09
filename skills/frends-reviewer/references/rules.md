# Rule catalogue

The rules `frends-reviewer` checks. Auto rules are checked by `scripts/review_process.py` on a
Process export; manual rules need the reviewer to read the Process, its specification and, for
some, the tenant settings.

Each rule has one of two origins. Platform rules are facts of the importer or runtime: they are
never switched off. Convention rules come from the Frends best practices collection and the
Frends guides: an organisation's own written standard overrides them (see
[house-standards.md](house-standards.md)).

## Severity

| Severity | Meaning |
| --- | --- |
| blocker | import fails, a secret leaks, or the contract is broken |
| major | a failure is hidden, recovery does not work, or a platform behaviour defeats the design |
| minor | readability, traceability or a convention |
| info | worth a look; not a defect by itself |

## Import (platform)

| Id | Rule | Severity | Check |
| --- | --- | --- | --- |
| IMP-01 | a Scope with a Catch has exactly two outgoing flows, the Catch listed first | blocker | auto |
| IMP-02 | the catch branch is one node whose single flow reaches the scope's own end shape | blocker | auto |
| IMP-03 | nothing branches after a Scope with a Catch | blocker | auto |
| IMP-04 | shape names are unique across the Process, including inside scopes; duplicate Return and Throw names are minor (seen in public templates) | blocker | auto |
| IMP-05 | the export passes the generator's structural validation | blocker | auto |

Detail: `../../frends-ipaas-developer/references/process-file-format/exception-handler-rules.md`,
`node-naming.md`, `generation-checklist.md` in the same folder.

## Error handling

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| ERR-01 | a handled failure ends in a Throw; a per-entity catch in a loop is followed by a Throw after the loop | platform | major | auto |
| ERR-02 | a validated and answered 4xx ends in a Return | convention | major | auto |
| ERR-03 | a 5xx ends in a Throw | convention | major | auto |
| ERR-04 | a Throw after the handler call sets `bypassGlobalExceptionHandler` | platform | minor | auto |
| ERR-05 | every business Process sets the unhandled-error hook | convention | major | auto |
| ERR-06 | the error handler and the error-event listener leave the hook empty | platform | major | auto |
| ERR-07 | recovery is stated per step: can it fail, retryable, partial state, recovery | convention | major | manual |
| ERR-08 | expected rejections are detected from returned results, not exceptions | convention | minor | manual |

## Retry

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| RTY-01 | shape retry is only set where the Task throws on failure | platform | major | auto |
| RTY-02 | retry count 5 or lower, or a stated reason | convention | minor | auto |
| RTY-03 | retry only on idempotent calls | convention | minor | auto (POST), manual |
| RTY-04 | retry only transient failures; never validation or business errors | convention | major | manual |

## Loops and performance

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| LOOP-01 | every While sets `maxIterations` from the design | platform | major | auto |
| LOOP-02 | no small Subprocess called inside a loop | convention | minor | auto |
| LOOP-03 | Inclusive Decision is not used for parallelism | platform | info | auto |
| LOOP-04 | no endless loop construct in a Code Task | platform | major | auto |
| LOOP-05 | a Foreach does not modify the collection it iterates | platform | major | manual |
| LOOP-06 | after a While, only `#var` carries per-iteration values | platform | major | manual |
| PERF-01 | incremental reads (watermark, cursor, keyset pagination) instead of full reloads | convention | minor | manual |
| PERF-02 | identifiers or filtered sets passed between components; large results disposed at scope end | convention | minor | manual |
| PERF-03 | no Remote Subprocess in a high-volume Process or API | convention | major | manual |

## Naming

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| NAM-01 | no brackets or special characters in Process and Subprocess names | convention | minor | auto |
| NAM-02 | no environment token in a name | convention | minor | auto |
| NAM-03 | no editor default or empty shape names | convention | minor | auto |
| NAM-04 | Process name shows source, target and purpose; Subprocess name shows function and whether it is shared | convention | minor | manual |
| NAM-05 | an API is named after the business capability | convention | minor | manual |
| NAM-06 | Environment Variables grouped by system, readable, documented | convention | minor | manual |

## Logging

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| LOG-01 | the correlation id and the primary business key are promoted | convention | minor | auto |
| LOG-02 | a correlation id is created or received and passed on | convention | minor | auto |
| LOG-03 | production Agent Groups log "Only errors"; "Log everything" only time-boxed | convention | major | manual |
| LOG-04 | payloads are not logged; stored payloads go to an external store | convention | minor | manual |
| LOG-05 | a scheduled or batch Process promotes its run counts | convention | minor | manual |

## Security

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| SEC-01 | no secret in a URL or query string | convention | major | auto |
| SEC-02 | no hard-coded credential | convention | blocker | auto |
| SEC-03 | secrets only in secret fields, or on shapes with Skip logging | convention | minor | auto (heuristic) |
| SEC-04 | no input concatenated into SQL text: `#trigger` is major, `#var` and `#result` minor | convention | major | auto |
| SEC-05 | external input is validated before use | convention | major | manual |
| SEC-06 | personal data in logs or archives is a recorded decision | convention | major | manual |
| SEC-07 | every published endpoint (API, HTTP, MCP trigger) requires authentication | convention | blocker | manual |

## Design

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| DES-01 | an approved specification exists before the build | convention | major | manual |
| DES-02 | one purpose per Process; roughly 50 execution shapes at most | convention | minor | auto (size), manual |
| DES-03 | a Subprocess exists for reuse, own cadence, size or ownership; one-off logic stays inline | convention | minor | manual |
| DES-04 | no Process waits inside a run for an external event; long work is split into stages | convention | major | manual |
| DES-05 | a dedicated Task is used where one exists | convention | minor | manual |
| DES-06 | a conditional trigger replaces a frequent schedule that mostly finds nothing | convention | minor | manual |
| DES-07 | a schedule that must not overlap is single instance; a file trigger runs one instance | platform | major | manual |
| STR-01 | size: more than 50 execution shapes | convention | minor | auto |
| STR-02 | a Code Task holds one logical action | convention | info | auto (length) |

## API

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| API-01 | the embedded OpenAPI document describes exactly one operation | platform | blocker | auto |
| API-02 | no `allOf`, `oneOf`, `anyOf` in the embedded document | platform | blocker | auto |
| API-03 | no YAML anchors or aliases | platform | blocker | auto |
| API-04 | concrete response codes, no `default` | convention | minor | auto |
| API-05 | the specification was approved before the build | convention | major | manual |
| API-06 | the API and its linked Processes are deployed together | convention | major | manual |
| API-07 | versioning decided at creation; breaking change is a new major version | convention | major | manual |

## Documentation and lifecycle

| Id | Rule | Origin | Severity | Check |
| --- | --- | --- | --- | --- |
| DOC-01 | a description states purpose; not the OpenAPI title | convention | minor | auto |
| DOC-02 | tags: one per external system | convention | info | auto |
| OPS-01 | every saved version carries a comment linked to the work item | convention | minor | manual |
| OPS-02 | another developer reviewed before handover | convention | major | manual |
| OPS-03 | operating instructions exist: purpose, dependencies, failures, recovery, contacts, maintenance, verification | convention | major | manual |
| OPS-04 | failure paths were provoked: downstream down, timeout, invalid input | convention | major | manual |

Custom Task rules (TSK-*) are in [custom-task-checklist.md](custom-task-checklist.md).

## Sources
- `https://docs.frends.com/guides/general/frends-best-practices-collection.md`
- `https://docs.frends.com/guides/general/common-errors-and-faq.md`
- `https://docs.frends.com/guides/development/frends-process-optimization.md`
- `https://docs.frends.com/guides/development/iteration-in-frends-processes.md`
- `https://docs.frends.com/guides/development/how-to-test-processes-and-tasks.md`

## Calibration
`review_process.py` was run over the 77 public templates in `FrendsPlatform/FrendsTemplates`:

| Rule | Templates | Reading |
| --- | --- | --- |
| ERR-05, LOG-01, LOG-02 | 77 | templates are portable and carry no hook or promoted values by design |
| IMP-04 (Returns and Throws) | 35 | duplicate Return names import through the template path |
| SEC-04 | 30 | `#trigger` and `#var` handlebars inside SQL queries |
| ERR-02 | 3 | a 400 answered through a Throw |
| RTY-01 | 2 | retry on an HTTP Task that does not throw on error responses |

Re-run it when a rule changes: a rule that fires on most templates without a real defect needs a
narrower check.
