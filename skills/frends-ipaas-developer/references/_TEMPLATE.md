# <Entity Name>

> Copy this file when adding a new shape, trigger, or concept. Keep the section
> headings; delete this quote block. One entity per file. Aim for tight, accurate
> prose over completeness — link out rather than repeat.
>
> The `../` links below assume this file has been copied **into a category
> subfolder** (`shapes/`, `triggers/`, or `concepts/`). They intentionally do not
> resolve from `references/` itself — fix them up for the destination folder depth.

**Category:** shape | trigger | concept
**Frends version baseline:** 6.2 / net8.0 (note older-version differences inline)

## Purpose
What this entity is and when to reach for it, in two or three sentences.

## Fields / configuration
Each configurable field, and for shape/trigger fields the **mode** it uses
(Expression / Text / select / toggle / integer / json / sql / xml — see
[../expressions/field-types.md](../expressions/field-types.md)). Note required vs
optional and any defaults.

## Expressions and references
Which `#` references are valid here and any field-type gotchas (e.g. "Decision
fields are locked to C# Expression"). Link to
[../expressions/reference-syntax.md](../expressions/reference-syntax.md).

## Serialization
How it appears in an exported Process file: the BPMN element, the JSON `Type`
code, and the `SelectedTypeId` if any. Link to the authoritative entry in
[../process-file-format/shape-type-codes.md](../process-file-format/shape-type-codes.md)
and, for confirmed parameter shapes,
[../process-file-format/confirmed-shape-parameters.md](../process-file-format/confirmed-shape-parameters.md).

## Gotchas
The Frends-specific traps that generic BPMN/C# intuition gets wrong.

## Example
A short, concrete shape-by-shape or JSON snippet.

## Source of truth
Where to confirm exact, version-sensitive detail (a `docs.frends.com` page — append
`.md`, or `?ask=<question>` — or Task source on the FrendsPlatform GitHub org).
