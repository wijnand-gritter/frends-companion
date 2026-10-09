# Templates, exports and the two import paths

Category: process-file-format · Baseline: Frends 6.2 and 6.3

## Purpose
How a Template export differs from a Process export, how to convert one into the other, and what
each import path validates. Read before importing a generated file, turning a Process into a
Template, or reading a public template from `FrendsPlatform/FrendsTemplates`.

Evidence labels: docs (docs.frends.com), import (observed by importing into a tenant),
corpus (counted over the 77 public templates).

## The two shapes

| Shape | Top level | Process record | Evidence |
| --- | --- | --- | --- |
| Process export | `Processes[]`, `LinkedTasks`, `LinkedSubProcess`, `Version` | `Processes[i]` | import |
| Template export | `ProcessTemplates[]` | `ProcessTemplates[0].ProcessInfo.Process`, with its own `LinkedTasks`, `LinkedSubProcess`, `Version` beside it | corpus |

A Template is a metadata wrapper (name, version, description, template tags, process tags,
`ProcessVariablesJson`) around one embedded Process export.

## Template to Process export
1. `ProcessTemplates[0].ProcessInfo.Process` becomes `Processes[0]`.
2. `ProcessInfo.LinkedTasks`, `LinkedSubProcess` and `Version` move to the top level.
3. Copy the wrapper's `ProcessVariablesJson` onto the Process record, or the variables are lost.
4. Set `GraphJson` to `""`, make `Modifier` non-null, and lower-case the GUIDs in `UsedTasksJson`
   (next section).
5. A new `UniqueIdentifier` needs `LinkedTasks` and `LinkedSubProcess` re-keyed to it
   ([proprietary-json.md](proprietary-json.md)).

The reverse wraps one Process record and its links in a new `ProcessTemplates[0]` with a new
template GUID.

## The two import paths validate differently

| Field | Template import | Process import | Evidence |
| --- | --- | --- | --- |
| `Process.GraphJson` | `null` accepted | must be `""`; `null` fails as not-null, `"{}"` fails as an old 4.2 Process | import |
| `Modifier` | `null` accepted | non-null required (`Value cannot be null. (Parameter 'modifier')`) | import |
| `UsedTasksJson` GUIDs | upper case | lower case | import |
| Process variables | on the wrapper | on the Process record | import |
| Duplicate Return and Throw names | accepted (35 of 77 public templates) | see [node-naming.md](node-naming.md) | corpus |

`generate_process.py` writes `GraphJson: ""` and a non-null `Modifier`.

## Portability: `#var` before `#env`
Public templates keep configuration in Process Variables (`#var.ApiBaseUrl`) with
`RequiredEnvironmentVariables` empty. Tenant Processes use `#env.Group.Name`. To make a Process into
a reusable template, move tenant-specific `#env` references into Process Variables with defaults
first; otherwise the target tenant needs identical Environment Variables. The docs endorse this
pattern (docs).

## Task GUIDs are per tenant
The GUID in `SelectedTypeId` (`/ProcessTask/<guid>/v<n>`), `UsedTasksJson` and `LinkedTasks[].Id`
identifies a Task in one tenant. `LinkedTasks[].PackageId` names the Task in words: match on it
when moving a Process between tenants, never on the GUID (import).

## Routes
| Need | MCP | Platform API | Files |
| --- | --- | --- | --- |
| List or export templates | none | `frends-templates.sh list`, `export` | Control Panel |
| Create a Process from a template | none | `frends-templates.sh create-process` | Control Panel |
| Import a Process export | none | `frends-process-push.sh` | Control Panel import |

## Sources
- `https://docs.frends.com/reference/process-development/template.md`
- `https://github.com/FrendsPlatform/FrendsTemplates` (77 templates)
- `https://github.com/OssiGalkin/OssisFrendsRecipes`, `references/templates-and-exports.md`: the
  import-path observations
