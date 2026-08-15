# Changelog

All notable changes to Frends Companion are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). The user-facing plugin version lives in
`fc-integration/.claude-plugin/plugin.json`; each release below corresponds to a `vX.Y.Z` git tag.

## [Unreleased]

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
- Command set finalized as `/fc-integration:connect`, `/fc-integration:new-workspace`, and
  `/fc-integration:clean`; the generated global scaffolder is now `/frends-init`.
- Removed third-party platform comparison references so the docs read as a standalone project.

### Fixed
- Corrected two serialization guesses against real 6.2 data: Type 21 is the DMN Task (not a data
  object reference), and Type 8 is a Scope (not Assign Variable).

## [0.1.0] - initial scaffold
- Initial Frends Companion plugin, marketplace, and bundled skill.

[Unreleased]: https://github.com/wijnand-gritter/frends-companion/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/wijnand-gritter/frends-companion/releases/tag/v0.3.0
[0.2.0]: https://github.com/wijnand-gritter/frends-companion/releases/tag/v0.2.0
