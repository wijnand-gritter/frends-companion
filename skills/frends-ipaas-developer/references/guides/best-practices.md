# Guide: Frends best practices

The default conventions this skill builds to, taken from the Frends best practices collection and
the Frends guides. They are conventions: where the organisation has a written standard, it wins
(see [../../SKILL.md](../../SKILL.md), "Platform facts vs conventions"). The `frends-reviewer`
skill checks a built Process against the same list.

## Design
| Rule | Detail |
| --- | --- |
| Design before building | goal, systems, sample payloads, mapping, owner, acceptance criteria, frequency, concurrency, latency, failure scenarios agreed first |
| One purpose per Process | split when a second purpose appears or the canvas passes roughly 40 to 50 execution shapes |
| Subprocesses for reuse | shared logic only; one-off logic stays inline ([subprocess-extraction.md](subprocess-extraction.md)) |
| No Remote Subprocess on high volume | extra overhead; pass identifiers only; payloads of 10 MB and more time out |
| Split long-running work | no Process waits inside a running instance for an external event; continue in a new stage on the event |
| Native shapes first | logic in Tasks, Decisions, Loops, Throws, DMN Tasks and Environment Variables; a Code shape for one action nothing else expresses ([native-shapes-first.md](native-shapes-first.md)) |
| Select Tasks deliberately | check the Task catalogue first; a dedicated Task over a generic HTTP or file Task |
| Conditional triggering | trigger on a condition instead of a frequent schedule that mostly finds nothing; no business logic in the condition |

## Data mapping
| Rule | Detail |
| --- | --- |
| JSON mapping in a Visual Data Mapper | on 6.4, a mapper before a Code shape; one mapper per target model ([native-shapes-first.md](native-shapes-first.md)) |
| Map from the payload, not the Task result | an Assign Variable such as `Read user from response body` between a Task and the mapper; a Task as the source maps its `Result` object ([../shapes/visual-data-mapper.md](../shapes/visual-data-mapper.md)) |
| One model, one schema, one place | a schema cannot come from a variable: it is a literal JSON string in the shape, and `#var.targetSchema` is rejected as invalid JSON. Within a Process, chain from the mapper: its result carries its target schema, so a later mapper uses it as source without a schema of its own. Across Processes, put the mapping in a shared Subprocess, e.g. `Shared - Map AFAS order to HubSpot deal`, so the schema and mappings exist once and a change is one deployment. For validation only, a JSON Schema validation Task with the schema in an Environment Variable or a file |
| Strict schema validation where the target is strict | turn it on when the receiving system rejects malformed input; a missing required field then fails the run with "Schema validation failed" |

## Naming
| Rule | Detail |
| --- | --- |
| Process names | readable, standardised, no brackets or special characters; source, target and purpose visible, e.g. `AFAS to HubSpot - Sync changes` |
| Subprocess names | say what it does and whether it is shared: `Shared - Handle process error` |
| API names | the business capability, never the backend system: `Customers`, `/customers/v1` |
| Environment Variables | grouped by system (`#env.Afas.BaseUrl`), no uncommon abbreviations, each documented |
| Shape names | unique per Process ([node-naming.md](../process-file-format/node-naming.md)); never the editor default |

## Errors
| Rule | Detail |
| --- | --- |
| General error handling in every main Process | scope, catch, shared handler, unhandled-error hook ([error-handling.md](error-handling.md)) |
| Handled failures stay visible | a caught failure ends in a Throw |
| Answered bad requests are successful runs | 4xx through a Return |
| Recovery planned per step | per step: can it fail, is it retryable, what partial state, how to recover |
| Retry transient failures only | limited count; never on validation or business errors |

## Logging
| Rule | Detail |
| --- | --- |
| Production on "Only errors" | Default truncates arrays at 100 elements and text at 10,000 characters; "Log everything" only time-boxed ([debugging.md](debugging.md)) |
| Identifiers, not payloads | correlation id, business key as promoted values; promoted values are logged at every level |
| Large payloads outside Frends | an external store, found through a promoted id |
| Sensitive data is a design decision | what, why, access, retention, deletion recorded; credentials never logged |

## Performance
| Rule | Detail |
| --- | --- |
| Clarity before optimisation | optimise a measured bottleneck only |
| Less data movement | pass ids or filtered sets, drop needless conversions |
| Incremental reads | watermark or cursor instead of a full reload; keyset pagination, not `OFFSET` |
| Memory | batches of 20 to 20,000 rows; agent memory below 70%; "Dispose at the end of the scope" on large results |
| Loops | no small Subprocess calls inside large loops; 2 to 3 parallel threads; Inclusive Decision runs serially ([../shapes/loop.md](../shapes/loop.md)) |

## Security
| Rule | Detail |
| --- | --- |
| Credentials | secret Environment Variables; never hard-coded |
| Secrets out of logs | secret Task fields; never in URLs or query strings; "Skip logging result and parameters" on shapes that carry them |
| Input validation | schema validation of API bodies, parameterised SQL, escaped LDAP filters, checked URLs, headers and files |

## API and lifecycle
| Rule | Detail |
| --- | --- |
| Design first | OpenAPI specification approved before the build ([../triggers/openapi-spec-constraints.md](../triggers/openapi-spec-constraints.md)) |
| Deploy API and Processes together | never split; operate from Test and Production |
| Version deliberately | version comment linked to the work item; API versioning decided at creation |
| Review before handover | another developer reviews Processes, Tasks and documentation |
| Operating instructions | purpose, dependencies, common failures, recovery, contacts, maintenance, verification |
| Test failure paths | provoke downstream failure, timeout, invalid input |

## Sources
- `https://docs.frends.com/guides/general/frends-best-practices-collection.md`
- `https://docs.frends.com/guides/development/frends-process-optimization.md`
- `https://docs.frends.com/guides/development/iteration-in-frends-processes.md`
- `https://docs.frends.com/guides/development/how-to-test-processes-and-tasks.md`
- `https://docs.frends.com/guides/general/common-errors-and-faq.md`
