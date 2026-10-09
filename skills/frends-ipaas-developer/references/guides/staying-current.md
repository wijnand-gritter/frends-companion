# Guide: staying current

This skill snapshots the durable core of Frends 6.2 and 6.3. For version-specific behavior, exact Task
parameters, new features, or anything not covered in the references, fetch the live docs — don't
guess at attribute names, Task parameters, trigger configs, or UI labels.

## How to query the docs
- Any docs page has a Markdown version: append `.md` to the path, e.g.
  `https://docs.frends.com/reference/process-development/c-in-frends.md`.
- Any docs page answers natural-language questions via a query parameter:
  `GET https://docs.frends.com/<path>.md?ask=<your specific question>`. Ask a specific,
  self-contained question.
- The full documentation as one LLM-readable file: `https://docs.frends.com/llms-full.txt`.
- The page index: `https://docs.frends.com/sitemap.md`.

## Source code as ground truth
Task source (to confirm exact parameters, enum members, and result objects) is open source under the
`FrendsPlatform` GitHub organization. The custom Task template is
`github.com/FrendsPlatform/FrendsTaskTemplate`. The Platform API surface is on the tenant at
`https://<tenant>.frendsapp.com/swagger`.

## When you rely on a fetched detail
Tell the developer it came from the live docs and note the version sensitivity if relevant. When
unsure of an exact name or label, say so and fetch rather than inventing it.

## Evidence labels
Every platform claim in this skill carries its evidence, in the file header or next to the claim:

| Label | Means |
| --- | --- |
| confirmed (export) | read from a real tenant export |
| confirmed (import) | observed by importing into a tenant |
| confirmed (MCP schema) | read from the Frends MCP server's tool schemas or guides |
| confirmed (OpenAPI) | read from the tenant's Platform API document |
| docs | stated on docs.frends.com |
| corpus | counted over the public `FrendsPlatform/FrendsTemplates` |
| inferred | reasoned, not observed: confirm before relying on it |

## Version coverage

| Frends | Status | Checked against |
| --- | --- | --- |
| 6.3.0 to 6.3.2 | supported | release notes 6.3.0, 6.3.1, 6.3.2 and breaking changes; MCP schemas, OpenAPI document and validation on 6.3.2.5468 |
| 6.2 | supported | tenant exports (serialisation), docs |
| 6.4 | not checked | run the refresh below |

## Refreshing on a new Frends minor version
Run when the tenant moves to a new Frends minor version (`get_overview` shows the version):

| Step | Check | Update |
| --- | --- | --- |
| 1 | release notes, `https://docs.frends.com/release-notes/` | the "Changed in" sections of the affected entity files |
| 2 | MCP `list_guides` and the `process-authoring` guide | [tooling-routes.md](tooling-routes.md), [mcp-build-conventions.md](mcp-build-conventions.md) |
| 3 | MCP tool schemas of the builder tools used in the overlay | the overlay's parameter column |
| 4 | `python3 scripts/check_api_drift.py swagger.json` | the scripts it reports as broken; then `--write` the snapshot |
| 5 | `FrendsPlatform/FrendsTasks`: `FrendsTaskTemplate`, `FrendsTaskSkills` | [../tasks/](../tasks/) |
| 6 | `frends-reviewer` over the public templates | rules that start firing without a real defect |
| 7 | one export of a Process with every shape the generator emits | [../process-file-format/](../process-file-format/), `FrendsVersion` default |

Record the version in `VERSION`, the CHANGELOG and the baselines of the files that changed.
