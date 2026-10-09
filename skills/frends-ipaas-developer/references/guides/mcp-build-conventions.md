# Guide: house conventions on the MCP route

How the house rules ([best-practices.md](best-practices.md) and the organisation's standard named in
`house_standards.md`) are applied through the MCP process builder. The `process-authoring` MCP guide
owns the tool mechanics; this file states the house rules and where they differ from that guide.
Pass it into the brief when handing a build to `frends:build-a-process` or a build loop.

## Precedence
1. Platform rules (import, compilation, runtime): always.
2. The organisation's standard named in `house_standards.md`.
3. This skill's defaults ([best-practices.md](best-practices.md)).
4. The `process-authoring` MCP guide's defaults.

## Rules and the MCP parameters that carry them

| House rule | MCP tool and parameter | Delta from the MCP guide |
| --- | --- | --- |
| Process name per the house standard; default `{Source} to {Target} - {Verb} {object}`, no brackets | `create_process_draft` `name`; `create_process_from_draft` `name` | none |
| Shape names: verb and object, sentence case (`Get records from source`) | `name` on every `process_add_*` | the guide shows Title Case (`Fetch Customer Records From CRM`); the house standard decides the case |
| Unique shape names across the Process | `name` | none |
| Handled failure ends in a Throw | `process_add_catch` → one `process_add_scope` → `process_add_call_activity` (shared handler) → `process_add_throw` with `bypassGlobalExceptionHandler: true`, inside the scope | the guide's handler rejoins the flow; the Throw inside the handler scope still ends the run as failed |
| Unhandled-error hook on every business Process | `process_set_error_handler` with every subprocess parameter given | none |
| Hook empty on the shared handler and the error listener | do not call `process_set_error_handler` | none |
| Answered 4xx ends in a Return | `process_add_return` `httpResult`, `httpStatusCode` mode `csharp` from the response variable, or one Return per status | none |
| 5xx ends in a Throw | `process_add_throw` | the MCP Throw carries an `expression` only; a Throw with an `HttpResult` body needs the editor or the file route |
| Promote the correlation id, the primary business key and run counts | `promoteResultAs` on the shape that produces each value | the guide says not to promote unless asked; the house standard is that request |
| Skip logging on shapes with secrets, personal data or large payloads | `shouldNotLogResultOrParameters: true` | none |
| Dispose large results | `shouldDispose: true` on the Task | none |
| Retry transient failures only, five at most | `shouldRetry: true`, `maxRetryCount` ≤ 5, with the Task's `ThrowExceptionOnErrorResponse` true | none |
| Expected rejections detected from results | Task `ThrowExceptionOnErrorResponse` false, then `process_add_decision` | none |
| Code in Code shapes, one action each | `process_add_expression` `useStatementMode: true`; a Code shape that ends in `return` needs `shouldAssignVariable: true` and a `variableName` (read it as `#var.<name>`), otherwise it compiles as void and fails with CS8030 (observed on 6.3.2.5468) | none |
| Configuration from existing Environment Variables only | `list_environment_variables` before every `#env` reference | none |
| No literal secrets in tool arguments | secret Environment Variable, value set by a person in the Control Panel | none |
| New Environment Variables on confirmation only | `create_environment_variable` after a yes | the guide creates them when the tool is available |
| Reuse shared Subprocesses | `list_processes` before building custom logic | none |
| Clean canvas | `forceRelayout: true` on the last mutation of a Process built in this session; ask before relayout of someone else's Process | none |
| Default Agent Group unless told otherwise | `deploy_process` `targetAgentGroupId` | none |
| Description states purpose, interface id and specification version | `create_process_draft` `description` | none |

## Gaps on the MCP route

| Need | Route |
| --- | --- |
| Process variables | Control Panel editor |
| Tags | `frends-tags.sh` (Platform API) |
| Throw with an `HttpResult` body | Control Panel editor, or the file route |
| Environment Variable values per Environment | `frends-env-vars.sh set` (Platform API) |
| Export for review outside the tenant | `get_process_data`, then `frends-reviewer --mcp-json` |

## After the build
1. `validate_process` passes.
2. `get_process_data` with the `draftId`, saved to a file, reviewed with
   `frends-reviewer` (`review_process.py --mcp-json`).
3. Blockers and majors fixed in the draft, then validated again.
4. Promotion only on the person's confirmation ([tooling-routes.md](tooling-routes.md)).

## Sources
- `get_guide('process-authoring')`, MCP tool schemas on Frends 6.3.2
