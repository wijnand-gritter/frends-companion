# Changelog

All notable changes to Frends Companion are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). The user-facing plugin version lives in
`fc-integration/.claude-plugin/plugin.json`; each release below corresponds to a `vX.Y.Z` git tag.

## [Unreleased]

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

[Unreleased]: https://github.com/wijnand-gritter/frends-companion/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/wijnand-gritter/frends-companion/releases/tag/v0.2.0
