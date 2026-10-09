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

## Gotchas
- **Set "Maximum concurrent instances" to 1** unless concurrent pickup is proven safe. Two
  instances racing for one file fail with `No source files found` or
  `RenameSourceFileBeforeTransfer - file not found`.
- The Agent service account needs read and write rights on the watched directory; without them the
  trigger turns blue, then red.
- Write output to a temporary folder first, never into a watched folder, so a partial file is not
  picked up.

## Source of truth
`https://docs.frends.com/reference/triggers/file-trigger.md`
