---
name: frends-reviewer
description: >-
  Review Frends work against the rules: Process and Subprocess exports (JSON or pulled from the
  tenant), API Processes and their embedded OpenAPI documents, and custom C# Task repositories.
  Use this skill whenever the user asks to review, check, audit, validate, approve or "look over" a
  Frends Process, Subprocess, API or custom Task, asks whether a Process follows the standards or
  best practices, prepares a G2 build review or a handover, or wants a second opinion before
  import or deployment. Also use it after frends-ipaas-developer generates a Process file. Prefer
  it over an unstructured opinion, because it checks platform import rules and conventions
  mechanically and reports findings with rule ids and fixes.
---

# Frends reviewer

Review Frends work and report findings. Do not change the reviewed files unless the user asks;
fixes are made with the `frends-ipaas-developer` skill.

## What to review

| Input | How |
| --- | --- |
| Process or Subprocess export (`.json`) | `scripts/review_process.py`, then the manual rules |
| A Process on the tenant | pull it with `frends-process-pull.sh` (frends-ipaas-developer), then as above |
| A BPMN-only export (`.bpmn`) | ask for the JSON export; BPMN carries no shape parameters |
| A generated Process from frends-ipaas-developer | as a JSON export, before it is delivered |
| A custom Task repository | [references/custom-task-checklist.md](references/custom-task-checklist.md) |

## Workflow

1. **Find the standard.** Look for a path in the request, then `house_standards.md` in the workspace
   root. Read the standard's documents. Without one, review against the Frends baseline and state
   that in the report. Precedence: [references/house-standards.md](references/house-standards.md).
2. **Run the automatic checks** on every export:

   ```bash
   python3 <skill-base-path>/scripts/review_process.py <export.json> [more.json] \
     [--disable RULE,RULE] [--pipeline "<handler name>"] [--format json]
   ```

   `--disable` switches off convention rules the house standard contradicts. `--pipeline` names
   the error handler and the error-event listener where their names are not recognised
   automatically. Exit code 2 means blockers, 1 majors.
3. **Check the manual rules** in [references/rules.md](references/rules.md). Read the Process: the
   canvas flow, Code Task bodies, Task parameters, trigger settings, description. Ask for what the
   export cannot show: the specification, the tenant log level, the operating instructions, the test
   evidence. A rule without the input goes under "Manual rules not assessable".
4. **Confirm each automatic finding before reporting it.** The security and naming checks are
   heuristics: drop a false positive and say why in one line.
5. **Report** in the format of [references/report-format.md](references/report-format.md): verdict,
   findings table, rules not assessable.
6. **Offer fixes.** List the fixes in severity order and offer to apply them with
   `frends-ipaas-developer`. A blocker is fixed before anything else is discussed.

## Rules in one view

| Area | Main rules |
| --- | --- |
| Import | caught-scope wiring, unique names, structural validity |
| Errors | handled failure ends in a Throw; answered 4xx ends in a Return; unhandled-error hook set; recovery per step |
| Retry | only where the Task throws; transient failures only; idempotent calls only |
| Loops | `maxIterations` set; no small Subprocess in a loop; Inclusive Decision is serial |
| Naming | no brackets, no environment tokens, no editor defaults; API named after the capability |
| Logging | correlation id and business key promoted; production on "Only errors" |
| Security | no secrets in URLs or code; secret fields or Skip logging; no SQL concatenation; input validated |
| API | one operation per embedded document; no compositions or anchors; deployed with its Processes |
| Lifecycle | description, tags, version comment, peer review, operating instructions, failure paths tested |

Platform rules come from confirmed importer and runtime behaviour and are never switched off.
Convention rules come from the Frends best practices collection and give way to a house standard.

## Sources
- Frends best practices collection: `https://docs.frends.com/guides/general/frends-best-practices-collection.md`
- Import behaviour: `../frends-ipaas-developer/references/process-file-format/`
