# File Trigger

**Category:** trigger · **Baseline:** Frends 6.2

## Purpose
Starts a Process on a file event — for example a file appearing on an SFTP path matching a filter.

## Configuration
Watched location/connection and a filename filter. Confirm the exact `config` field set against the
live docs or a real export.

## Expressions and references
Trigger parameter fields are Text with the `#env` exception; see
[parameter-fields.md](parameter-fields.md). The matched file's metadata is exposed via `#trigger`.

## Serialization
JSON `Type` 0, `SelectedTypeId: "FileWatchTrigger"`. **Confirmed** 6.2 `config` keys: `version`,
`dirToWatch`, `fileMask`, `includeSubDirectories`, `maxFilesPerBatch`, `pollIntervalSeconds`. See
[../process-file-format/triggers-encoding.md](../process-file-format/triggers-encoding.md).

## Source of truth
`https://docs.frends.com/reference/triggers/file-trigger.md`
