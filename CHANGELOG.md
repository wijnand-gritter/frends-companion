# Changelog

All notable changes to Frends Companion are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). The user-facing plugin version lives in
`.claude-plugin/plugin.json`. Releases from 0.5.0 onward are tagged
`frends-companion-developer--vX.Y.Z`, the convention `claude plugin tag` writes. Earlier
versions were released from a different repository and have no tag here.

## [Unreleased]

### Changed
- Moved the plugin to its own repository
  (`repo.virtualsciences.nl/ai-pilot/frends-companion`) and renamed it from `fc-integration` to
  **`frends-companion-developer`**. The repo root is now the plugin, and the catalogue entry lives in
  the Conclusion marketplace (`repo.virtualsciences.nl/ai-pilot/conclusion-marketplace`).
  **Breaking for existing users:** uninstall `fc-integration@frends-companion`, then
  `/plugin marketplace add https://repo.virtualsciences.nl/ai-pilot/conclusion-marketplace.git` and
  `/plugin install frends-companion-developer@conclusion`. Slash commands move from
  `/fc-integration:*` to `/frends-companion-developer:*`; the bundled skill keeps the name
  `frends-ipaas-developer`.
- CI moved from GitHub Actions to GitLab CI (`.gitlab-ci.yml`); the Markdown link checker now lives
  at `scripts/check_links.py`.
- The README now opens with what to install before starting, naming `bash`, `curl` and `jq`, which
  the Platform API tools require and which it never mentioned, with a macOS and a Windows column for
  each. Install covers the terminal and the desktop app rather than the terminal alone, the git
  token is stated rather than linked away, and keeping the two channels in step has its own section.
  It follows the shape of the marketplace README, so a reader moving between the two finds the same
  headings in the same order.

## [0.5.0] - 2026-08-19

### Added
- `references/triggers/mcp.md`: the Frends 6.3 MCP Trigger (expose a Process as an MCP tool),
  docs-sourced with an explicit harvest-first block - serialization is unconfirmed.
- Frends 6.3 release notes folded into the affected references: AI Connector MCP Tools tab and
  opt-in reasoning (`shapes/ai-connector.md`), RabbitMQ client-certificate authentication
  (`triggers/rabbitmq.md`), OpenAPI 3.1.1 + mTLS on API Triggers (`triggers/api.md`,
  `triggers/openapi-spec-constraints.md`), Agent Registration Modes / .NET Runtime 10.0.5
  requirement / 6.4 Legacy Agent removal (`concepts/agent-and-agent-group.md`,
  `guides/deployment.md`), and the API Policy auth migration
  (`concepts/api-management.md`).
- `references/process-file-format/canvas-layout-conventions.md`: when a container collapses to a
  single shape, close the gap instead of centring the survivor in the old footprint, and shift the
  rest of the row left by the difference. Imports fine either way, which is why it goes unnoticed.
- `references/shapes/task.md`: an imported `ShouldRetry` / `MaxRetryCount` can read as empty in the
  editor's retry panel while being present and correct in the file; verify by export, not by panel.
- `references/shapes/task.md`: built-in **Retry on failure** semantics - `ShouldRetry` /
  `MaxRetryCount` (max 10) live on the shape, retries fire on exception only, and the wait is
  exponential `500ms * 2^n` (1s, 2s, 4s, 8s, 16s ...). Documented the pairing with an HTTP Task's
  `ThrowExceptionOnErrorResponse`, which turns a non-2xx into an exception so shape retry applies,
  replacing a five-shape hand-built While retry loop; plus when a hand-built loop is still
  justified (`Retry-After`, proactive pacing, selective statuses) and the 207-is-not-success trap.
- `references/triggers/openapi-spec-constraints.md`: the embedded `openApiDocument` must describe
  exactly **one** operation. A whole-API document breaks API Management binding: "API Spec not
  found", the Process lands under Unlinked processes, and every affected Process is grouped under
  the first path in its document rather than its own route. Documented what stays whole
  (`components`, `tags`, `security`, `info`, `servers`), that deleting and re-adding the trigger is
  the symptom rather than the fix, and a verified recipe for reproducing the editor's YAML
  serialization when slicing the document per operation.

### Changed
- Separated platform facts from conventions so the skill is safe to share outside the organisation
  that wrote it. `SKILL.md` states the precedence (platform facts are not negotiable; an
  organisation's own written standard beats this skill's default convention).
- `references/guides/error-handling.md`: the circuit-breaker snippet no longer hard-codes one
  tenant's process names; it uses placeholders and notes what to match on.
- `references/guides/code-shape-style.md`: labelled "a default, not a rule", with the
  non-negotiable platform behaviour called out separately.
- `references/process-file-format/canvas-layout-conventions.md`: the color legend is presented as
  one workable default rather than the assignment, green is described honestly as unassigned in the
  default with the happy-path variant named, and the tag scheme is generic.
- `references/process-file-format/generation-checklist.md`: the Description/Tags rule is a default;
  the OpenAPI-title gotcha stays mandatory because it is platform behaviour.

## [0.4.0] - 2026-08-16

### Added
- `references/guides/code-shape-style.md`: house C# style for Code shapes - full-word variable
  naming (no single letters or abbreviations; `i`/`j` loop counters excepted), the
  token/cast-pair pattern for JArray iteration, full-word `#var` names (`readControl`, not
  `readCtrl`), sparse why-not-what comments, and formatting rules.
- `references/guides/error-handling.md`: the "Subprocess to call on unhandled error" hook -
  reporting-only semantics, the absence of platform loop protection, the wiring table (business
  processes point at the shared handler; the handler and the error-event listener stay empty),
  and the never-throws + circuit-breaker design rules that make a shared handler safe to hook.
- `references/triggers/manual.md`: Manual Trigger parameter values are not guaranteed to be
  strings - Json.NET date parsing turns ISO-datetime-looking values into `System.DateTime`, so
  `(string)#trigger.data.x` throws `RuntimeBinderException` at runtime; documented the tolerant
  `Convert.ToString` + `is DateTime` pattern.
- `references/shapes/shared-state-task.md`: the same Json.NET conversion applies to Shared State
  `.Value` on read - an ISO-datetime string stored as a string comes back as `System.DateTime`,
  so a blind `(string)` cast fails from the second run onward (the first run takes the not-found
  default, so tests miss it); documented the tolerant read pattern for watermark-style values.
- Readability conventions in `canvas-layout-conventions.md`: the semantic color legend
  (red error / orange write / blue read / purple state / pink waiting), text-annotation rules
  (why-not-what, ~15 words, 2-4 per process), and group rules (top-level phases only, labelled,
  never nested or inside Scopes).
- `references/guides/subprocess-extraction.md`: the extract-vs-keep checklist for Subprocesses and
  the deploy-order tax, as advisory design feedback.
- `references/triggers/manual.md`: confirmed Manual Trigger parameter encoding -
  `ManualTriggerJson` field set (incl. `isSecret`), positional `manualTriggerDefaultValue-N`
  defaults mirrored in the trigger config and EP entry, `#trigger.data.<name>` string values, and
  the multi-trigger routing pattern on `#trigger.name`.
- `references/shapes/group.md` and `references/shapes/text-annotation.md`: confirmed 6.3
  serialization for the documentation-only shapes - group/category/categoryValue structure,
  textAnnotation/association structure, diagonal association edges, and the rule that none of
  them carry `ElementParameters` entries. Shape-color DI encoding (`bioc:fill` +
  `color:background-color`, editor palette) documented in `canvas-layout-conventions.md`.
- Generation checklist: every process carries a present-tense `Description` and one system tag
  per external system it touches.
- `references/shapes/shared-state-task.md`: all eight Shared State operations confirmed from a 6.3
  export - the uniform full parameter set required by every operation, `ttlMultiplier` unit
  semantics (60/3600), the `#result.Success`/`.Value`/`.Message` contract, the
  TryGetValue-with-default and GetOrAdd watermark patterns, and `PromoteResultAs` +
  `PromotedResultVariablesJson`.
- `references/triggers/schedule.md`: full confirmed Schedule Trigger config from configured 6.3
  exports - `repeatDelayType` unit-multiplier semantics with precomputed `repeatDelaySeconds`,
  `recurring` window vs fire-at-startTime behavior, Windows time-zone ids,
  `datesToExclude`/`openOnlyOnDates`, and that multiple Schedule Triggers per process are allowed
  (the one-trigger limit is API-Trigger-specific).
- `references/shapes/loop.md`: confirmed While/Foreach serialization from a 6.3 tenant export -
  loop markers (`standardLoopCharacteristics` vs `multiInstanceLoopCharacteristics isSequential`),
  the full parameter shapes (`maxIterations`/`expression`; plain-string `variable`), the dual
  meaning of `standardLoopCharacteristics` (task retry vs While), and the pre-test rule that While
  conditions must be driven by `#var` control state, not body `#result`s.

## [0.3.0] - 2026-08-15

### Added
- `references/triggers/openapi-spec-constraints.md`: the Frends-specific OpenAPI rules for API
  Triggers - one API Trigger per process, flat schemas with literal `properties` (no `allOf`),
  no YAML anchors/aliases, concrete response codes - with the symptom-to-cause table and a
  known-good skeleton.
- `references/process-file-format/node-naming.md`: node names must be unique across the whole
  process (including inside scopes); the import error, the exemptions, and a validation rule for
  generated files.
- `references/process-file-format/structured-flow-rules.md`: the import parser's structured-flow
  requirement - gateway branches must terminate or reconverge at one node, properly nested - and
  the two envelope styles that satisfy it.
- `references/process-file-format/canvas-layout-conventions.md`: DI conventions calibrated against
  hand-arranged editor exports (shape sizes by role, lane spacing, error-rail routing, catch
  placement, tags).
- `references/expressions/result-reference-scope.md`: `#result` is compiled to C# locals under
  definite-assignment rules (CS0165); referencing a conditionally-executed shape's result after a
  join fails to import - promote to `#var` on the producing branch.
- `references/triggers/api.md`: the one-API-Trigger-per-process rule and the spec-constraints
  pointer.
- Generation checklist: caveats for name uniqueness, structured joins, `#result` scope, the
  json-mode string trap, gateway-condition placement, and canvas conventions.
- SKILL.md router entries and two new "conventions generic knowledge gets wrong" bullets for the
  above.

### Changed
- `frends-canvas-arranger` agent: layout guidance replaced with the calibrated house conventions
  (references `canvas-layout-conventions.md`).
- New and corrected references carry "Baseline: Frends 6.3" where confirmed against a 6.3 tenant.

### Fixed
- `references/shapes/assign-variable.md`: serialization was documented as "Type 8 likely"; an
  Assign is a `scriptTask` / Type 12 distinguished by its `variableName` parameters. Documented the
  per-mode runtime types (json mode holds JSON text, not a parsed object).
- `references/shapes/exclusive-decision.md`: branch conditions were documented as living on the
  outgoing `sequenceFlow` entries; the condition lives on the gateway's own entry, and labeled
  flows carry empty `Parameters` with `IsDefault` flags.

## [0.2.0] - 2026-07-03

### Added
- Full entity-per-file `frends-ipaas-developer` skill: per-file concepts, triggers, shapes,
  expressions, custom-Task authoring, and a split process-file-format spec, with a per-folder
  `_index.md`, a `CONTRIBUTING.md`, and a copy-to-extend `_TEMPLATE.md`.
- Complete shape coverage (22 shapes) and trigger coverage (11 triggers), including Shared State,
  DMN, AI Connector, Intermediate Return, the long-running shapes (Checkpoint / Scheduled Resume /
  Signal Resume), the artifact/documentation shapes, Sequence Flow, and the messaging triggers
  (AMQP, Service Bus, RabbitMQ, Azure Event Hub, TCP).
- Serialization spec (`references/process-file-format/`) confirmed against real Frends 6.2 exports,
  including a full Type-code table and all 11 trigger `$type`/`config` shapes.
- Frends Platform API CLI tools (`frends-*.sh`) and the `frends-canvas-arranger` agent.
- Single-repo marketplace manifest at `.claude-plugin/marketplace.json`.

### Changed
- Command set finalized as `/frends-companion-developer:connect`, `/frends-companion-developer:new-workspace`, and
  `/frends-companion-developer:clean`; the generated global scaffolder is now `/frends-init`.
- Removed third-party platform comparison references so the docs read as a standalone project.

### Fixed
- Corrected two serialization guesses against real 6.2 data: Type 21 is the DMN Task (not a data
  object reference), and Type 8 is a Scope (not Assign Variable).

## [0.1.0] - initial scaffold
- Initial Frends Companion plugin, marketplace, and bundled skill.

[Unreleased]: https://repo.virtualsciences.nl/ai-pilot/frends-companion/-/compare/frends-companion-developer--v0.5.0...main
[0.5.0]: https://repo.virtualsciences.nl/ai-pilot/frends-companion/-/tags/frends-companion-developer--v0.5.0
