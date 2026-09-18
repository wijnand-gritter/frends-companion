# frends-ipaas-developer

A Claude skill that turns Claude into an expert Frends iPaaS integration developer: designing BPMN
2.0 Process flows, writing Frends C# expressions and Code Tasks, authoring custom C# Tasks, planning
deployments, debugging Process Instances, generating importable Process files, and driving the Frends
Platform API.

## How it's organized

`SKILL.md` is a **router**. The knowledge lives in small, single-purpose files under `references/`,
organized **by entity** so the skill is easy to extend:

```
references/
  concepts/            one file per platform entity (Process, Agent, Environment, ...)
  triggers/            one file per trigger type (+ parameter-fields.md)
  shapes/              one file per canvas shape (Task, Decision, Loop, ...)
  expressions/         the cross-cutting C# layer (field types, references, namespaces, ...)
  guides/              cohesive workflow essays (bpmn-modeling, deployment, debugging, ...)
  process-file-format/ the export/import spec, split; real 6.2 exports under examples/
scripts/               Platform API CLI tools (frends-*.sh) + the Process generator
```

To add a shape, trigger, or concept, copy `references/_TEMPLATE.md` into the right folder and add one
router line to `SKILL.md`. Full instructions are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Baseline

Targets Frends 6.2 / net8.0. Version-sensitive specifics (exact Task parameters, enum members,
trigger configs) are deferred to the live docs — see `references/guides/staying-current.md`.

## Scripts

The `frends-*.sh` tools wrap the Frends Platform API (list/pull/push/deploy/run/monitor) and
`generate_process.py` builds importable Process JSON. The Platform API scripts are scaffolded from the
published 6.2 reference and not yet live-tested — validate against your tenant's `/swagger`. See
`references/guides/cli_tool_reference.md`.
